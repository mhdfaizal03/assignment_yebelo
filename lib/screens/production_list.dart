import 'dart:convert';
import 'package:assignment/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  String selectedCategory = 'All';
  TextEditingController quantityController = TextEditingController();
  List images = [
    const AssetImage('assets/images/appejpeg.jpeg'),
    const AssetImage('assets/images/mangojpg.jpg'),
    const AssetImage('assets/images/banana.jpg'),
    const AssetImage('assets/images/orange.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    String jsonProducts =
        '[{"p_name":"Apple","p_id":1,"p_cost":30,"p_availability":1,"p_details":"Imported from Swiss","p_category":"Premium"},{"p_name":"Mango","p_id":2,"p_cost":50,"p_availability":1,"p_details":"Farmed at Selam","p_category":"Tamilnadu"},{"p_name":"Bananna","p_id":3,"p_cost":5,"p_availability":0},{"p_name":"Orange","p_id":4,"p_cost":25,"p_availability":1,"p_details":"from Nagpur","p_category":"Premium"}]';
    List<dynamic> decodedJson = jsonDecode(jsonProducts);
    Set<int> productIds = {};
    allProducts = decodedJson.map((e) {
      if (productIds.contains(e['p_id'])) {
        int newId = e['p_id'] + 1;
        while (productIds.contains(newId)) {
          newId++;
        }
        e['p_id'] = newId;
      }
      productIds.add(e['p_id']);
      return ProductModel.fromJson(e);
    }).toList();
    filteredProducts = List.from(allProducts);
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P R O D U C T L I S T'),
        centerTitle: true,
        backgroundColor: Colors.black38,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Padding(
                  padding: EdgeInsets.only(top: value * 30),
                  child: child,
                );
              },
              child: DropdownButton<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                    filterProducts();
                  });
                },
                items: <String>['All', 'Premium', 'Tamilnadu']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(25),
                    leading: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(seconds: 3),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: images[index],
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                        'Category: ${product.category}\nCost: Rs ${product.cost.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        _showQuantityDialog(product);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black26),
                elevation: MaterialStateProperty.all(5),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 50))),
            onPressed: () {
              submit();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void filterProducts() {
    if (selectedCategory == 'All') {
      setState(() {
        filteredProducts = List.from(allProducts);
      });
    } else {
      setState(() {
        filteredProducts = allProducts
            .where((product) => product.category == selectedCategory)
            .toList();
      });
    }
  }

  void _showQuantityDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter quantity for ${product.name}:'),
          content: TextField(
            decoration: const InputDecoration(
                hintText: 'enter the quantity',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)))),
            controller: quantityController,
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                int quantity = int.tryParse(quantityController.text) ?? 0;
                setState(() {
                  product.quantity = quantity;
                });
                print('Product: ${product.name}, Quantity: $quantity');
                quantityController.clear();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void submit() {
    List<Map<String, dynamic>> jsonList =
        filteredProducts.map((product) => product.toJson()).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Submitted Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text(jsonEncode(jsonList))],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadProducts() async {
    String jsonProducts = await rootBundle.loadString('assets/products.json');
    List<dynamic> decodedJson = jsonDecode(jsonProducts);
    allProducts = decodedJson.map((e) => ProductModel.fromJson(e)).toList();
    filteredProducts = List.from(allProducts);
  }
}
