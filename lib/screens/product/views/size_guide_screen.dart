import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';

class SizeGuideScreen extends StatefulWidget {
  const SizeGuideScreen({super.key});

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  bool _isShowCentimetersSize = false;

  void updateSizes() {
    setState(() {
      _isShowCentimetersSize = !_isShowCentimetersSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 40,
                    child: BackButton(),
                  ),
                  Text(
                    "Size guide",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        "assets/icons/Share.svg",
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color!,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle Buttons
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!_isShowCentimetersSize) updateSizes();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _isShowCentimetersSize ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Centimeters",
                                  style: TextStyle(
                                    color: _isShowCentimetersSize ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                                    fontWeight: _isShowCentimetersSize ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_isShowCentimetersSize) updateSizes();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !_isShowCentimetersSize ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Inches",
                                  style: TextStyle(
                                    color: !_isShowCentimetersSize ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                                    fontWeight: !_isShowCentimetersSize ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 1.5),
                    
                    // Table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Table(
                          border: TableBorder.all(
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1.2),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1.2),
                            4: FlexColumnWidth(1.2),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                              ),
                              children: [
                                _buildTableCell("", isHeader: true, hasStripes: true),
                                _buildTableCell("Size", isHeader: true),
                                _buildTableCell("Bust", isHeader: true),
                                _buildTableCell("Waist", isHeader: true),
                                _buildTableCell("Hips", isHeader: true),
                              ],
                            ),
                            _buildTableRow("XS", "0", "32", "24-25", "34-35"),
                            _buildTableRow("S", "2-4", "34", "26-27", "36-39"),
                            _buildTableRow("M", "6-8", "36", "28-29", "38-39"),
                            _buildTableRow("L", "10-12", "38-40", "31-33", "41-43"),
                            _buildTableRow("XL", "14", "42", "34", "44"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    
                    // Measurement Guide
                    Text(
                      "Measurement Guide",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: defaultPadding),
                    const Divider(),
                    const SizedBox(height: defaultPadding),
                    Text(
                      "Bust",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      "Measure under your arms at the fullest part of your bust. Be sure to go over your shoulder blades.",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 1.5),
                    Text(
                      "Natural Waist",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      "Measure around the narrowest part of your waistline with one forefinger between your body and the measuring tape.",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String col1, String col2, String col3, String col4, String col5) {
    return TableRow(
      children: [
        _buildTableCell(col1),
        _buildTableCell(col2),
        _buildTableCell(col3),
        _buildTableCell(col4),
        _buildTableCell(col5),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool hasStripes = false}) {
    // If it's the striped corner, return a placeholder container
    if (hasStripes) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
      );
    }
    
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.w500 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
