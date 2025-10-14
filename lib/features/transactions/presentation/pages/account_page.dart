import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 40, child: Text('J', style: Theme.of(context).textTheme.headlineSmall)),
            const SizedBox(height: 24),
            Text('Username', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            const Text('john'),
            const SizedBox(height: 24),
            Text('Language', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
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
