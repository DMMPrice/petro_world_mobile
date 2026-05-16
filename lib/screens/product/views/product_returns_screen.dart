import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants.dart';
import '../../../providers/providers.dart';

class ProductReturnsScreen extends ConsumerWidget {
  const ProductReturnsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Returns & Exchanges",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            settingsAsync.when(
              data: (settings) => Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(defaultPadding),
                    padding: const EdgeInsets.all(defaultPadding * 1.2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2ED573).withValues(alpha: 0.05),
                          const Color(0xFF2ED573).withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2ED573).withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2ED573).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.assignment_return_outlined,
                                  color: Color(0xFF2ED573), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Return Policy",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1B8A44),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          settings['return_policy'] ??
                              "No return policy specified. Please contact support for more information.",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(defaultPadding * 2),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text("Error: $e"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
