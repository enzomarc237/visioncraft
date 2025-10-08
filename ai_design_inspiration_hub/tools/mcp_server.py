#!/usr/bin/env python3
import argparse
import json
import os
import sqlite3
from http.server import BaseHTTPRequestHandler, HTTPServer


def read_db_path():
    # Keep in sync with Flutter app database location logic if needed.
    # For dev convenience, allow an env override.
    return os.environ.get('AIDH_DB_PATH')


def auth_ok(headers):
    api_key = os.environ.get('MCP_API_KEY')
    if not api_key:
        return True
    provided = headers.get('Authorization') or headers.get('authorization')
    return provided == f"Bearer {api_key}"


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if not auth_ok(self.headers):
            self.send_response(401)
            self.end_headers()
            self.wfile.write(b'Unauthorized')
            return

        length = int(self.headers.get('Content-Length', '0'))
        body = self.rfile.read(length)
        try:
            req = json.loads(body.decode('utf-8'))
        except Exception:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'Invalid JSON')
            return

        method = req.get('method')
        params = req.get('params', {})
        try:
            if method == 'listScreenshots':
                result = list_screenshots(params)
            elif method == 'getScreenshotMetadata':
                result = get_screenshot_metadata(params)
            elif method == 'getDesignSpecifications':
                result = get_design_specifications(params)
            else:
                raise ValueError('Unknown method')
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'result': result}).encode('utf-8'))
        except Exception as e:
            self.send_response(400)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': {'message': str(e)}}).encode('utf-8'))


def _connect():
    db_path = read_db_path()
    if not db_path or not os.path.exists(db_path):
        raise RuntimeError('Database path not set or does not exist')
    return sqlite3.connect(db_path)


def list_screenshots(params):
    limit = int(params.get('pagination', {}).get('limit', 20))
    offset = int(params.get('pagination', {}).get('offset', 0))
    with _connect() as conn:
        cur = conn.cursor()
        cur.execute(
            'SELECT id, title, description, image_path, creation_date FROM Screenshots ORDER BY creation_date DESC LIMIT ? OFFSET ?;',
            (limit, offset),
        )
        rows = cur.fetchall()
        cur.execute('SELECT COUNT(1) FROM Screenshots;')
        total = cur.fetchone()[0]
    screenshots = [
        {
            'id': r[0],
            'title': r[1],
            'description': r[2],
            'image_path': r[3],
            'creation_date': r[4],
            'tags': [],
            'categories': [],
        }
        for r in rows
    ]
    return {'screenshots': screenshots, 'total_count': total}


def get_screenshot_metadata(params):
    screenshot_id = params.get('screenshot_id')
    if not screenshot_id:
        raise ValueError('screenshot_id is required')
    with _connect() as conn:
        cur = conn.cursor()
        cur.execute(
            'SELECT id, title, description, image_path, creation_date, source_url, upload_timestamp FROM Screenshots WHERE id = ? LIMIT 1;',
            (screenshot_id,),
        )
        row = cur.fetchone()
        if not row:
            raise ValueError('Not found')
    return {
        'id': row[0],
        'title': row[1],
        'description': row[2],
        'image_path': row[3],
        'creation_date': row[4],
        'source_url': row[5],
        'upload_timestamp': row[6],
        'tags': [],
        'categories': [],
        'has_design_specs': True,
    }


def get_design_specifications(params):
    screenshot_id = params.get('screenshot_id')
    if not screenshot_id:
        raise ValueError('screenshot_id is required')
    with _connect() as conn:
        cur = conn.cursor()
        cur.execute(
            'SELECT id, layout_structure, ui_components, color_palette, typography, general_design_info, analysis_timestamp, analysis_engine_version FROM Design_Specifications WHERE screenshot_id = ? LIMIT 1;',
            (screenshot_id,),
        )
        row = cur.fetchone()
        if not row:
            raise ValueError('Not found')
    return {
        'id': row[0],
        'screenshot_id': screenshot_id,
        'layout_structure': json.loads(row[1]) if row[1] else None,
        'ui_components': json.loads(row[2]) if row[2] else None,
        'color_palette': json.loads(row[3]) if row[3] else None,
        'typography': json.loads(row[4]) if row[4] else None,
        'general_design_info': json.loads(row[5]) if row[5] else None,
        'analysis_timestamp': row[6],
        'analysis_engine_version': row[7],
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=8765)
    args = parser.parse_args()

    httpd = HTTPServer(('127.0.0.1', args.port), Handler)
    print(f"MCP-like server running on http://127.0.0.1:{args.port}")
    httpd.serve_forever()


if __name__ == '__main__':
    main()

