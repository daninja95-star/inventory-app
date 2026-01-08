from flask import Flask, jsonify, request

app = Flask(__name__)

inventory = {
    "SKU001": {"name": "Laptop", "stock": 10},
    "SKU002": {"name": "Mouse", "stock": 50},
    "SKU003": {"name": "Keyboard", "stock": 25}
}

@app.route('/')
@app.route('/products')
def list_products():
    """
    Returns a JSON list of all products.
    Accessible at both the root URL (/) and /products.
    """
    return jsonify(inventory)

@app.route('/products/<sku>', methods=['GET'])
def get_product_stock(sku):
    product = inventory.get(sku)
    if product:
        return jsonify(product)
    return jsonify({"message": "Product not found"}), 404

@app.route('/products/<sku>/add', methods=['POST'])
def add_stock(sku):
    data = request.get_json()
    amount = data.get('amount')
    if not isinstance(amount, int) or amount <= 0:
        return jsonify({"message": "Invalid amount"}), 400

    if sku not in inventory:
        return jsonify({"message": "Product not found"}), 404

    inventory[sku]["stock"] += amount
    return jsonify(inventory[sku])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080) # Cloud Run typically uses 8080
