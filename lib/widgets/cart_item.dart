import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final double price;
  final int quantity;
  final String title;
  final String productId;

  CartItem(this.id, this.price, this.quantity, this.title, this.productId);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 20,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(
                  child: Text('\$$price'),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total \$${(price * quantity)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
      confirmDismiss: (direction) => showDialog<bool>(
        context: context,
        builder: (builderContext) => AlertDialog(
          title: Text('Are you sure you want to delete?'),
          content: Text('Do you want to remove the item from the cart?'),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(builderContext).pop(false),
              child: Text('No'),
            ),
            FlatButton(
              onPressed: () => Navigator.of(builderContext).pop(true),
              child: Text('Yes'),
            ),
          ],
        ),
      ),
      onDismissed: (direction) =>
          Provider.of<Cart>(context, listen: false).removeItem(productId),
    );
  }
}
