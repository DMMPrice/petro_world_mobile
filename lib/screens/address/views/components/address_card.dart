import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../constants.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.isActive = false,
    required this.press,
  });

  final String name, address, phoneNumber;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive
                ? primaryColor
                : Theme.of(context).dividerColor.withOpacity(0.1),
            width: isActive ? 2 : 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              "assets/icons/Location.svg",
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                isActive ? primaryColor : Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  Text(
                    address,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  Text(
                    phoneNumber,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
