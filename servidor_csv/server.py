from flask import Flask, send_file, abort

app = Flask(__name__)

CSV_FILES = {
    "order.csv": "order.csv",
    "order_item.csv": "order_item.csv"
}

@app.route('/csv/<filename>', methods=['GET'])
def get_csv(filename):
    if filename in CSV_FILES:
        return send_file(CSV_FILES[filename], as_attachment=True)
    else:
        abort(404, description="File not found")

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=True)
