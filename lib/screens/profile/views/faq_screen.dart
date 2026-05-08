import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/supabase_service.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _faqs = [];

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    try {
      final faqs = await SupabaseService.getFaqs();
      setState(() {
        _faqs = faqs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load FAQs: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Frequently Asked Questions"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _faqs.isEmpty
              ? const Center(child: Text("No FAQs available."))
              : ListView.separated(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: _faqs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: defaultPadding),
                  itemBuilder: (context, index) {
                    final faq = _faqs[index];
                    return CustomAccordion(
                      title: faq['question'] ?? 'No Question',
                      content: Text(
                        faq['answer'] ?? 'No Answer',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color!
                              .withOpacity(0.8),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class CustomAccordion extends StatefulWidget {
  const CustomAccordion({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;

  @override
  State<CustomAccordion> createState() => _CustomAccordionState();
}

class _CustomAccordionState extends State<CustomAccordion> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isOpen = !_isOpen),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: primaryColor,
            ),
          ),
          if (_isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.content,
            ),
        ],
      ),
    );
  }
}
