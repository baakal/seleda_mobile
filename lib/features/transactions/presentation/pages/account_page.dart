import 'package:flutter/material.dart';
import 'package:seleda_finance/features/transactions/presentation/style.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: TxStyles.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 40, child: Text('J', style: Theme.of(context).textTheme.headlineSmall)),
            const SizedBox(height: TxStyles.spaceXl),
            Text('Username', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: TxStyles.spaceXs),
            const Text('john'),
            const SizedBox(height: TxStyles.spaceXl),
            Text('Language', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: TxStyles.spaceSm),
            Wrap(
              spacing: TxStyles.spaceSm,
              children: const [
                Chip(label: Text('English')),
                Chip(label: Text('Amharic')),
                Chip(label: Text('Tigrigna')),
                Chip(label: Text('Oromiffa')),
              ],
            ),
            const Spacer(),
            FilledButton(onPressed: () {}, child: const Text('Tutorial (Coming Soon)')),
          ],
        ),
      ),
    );
  }
}
