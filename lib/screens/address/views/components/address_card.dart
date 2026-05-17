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
    this.onEdit,
    this.onDelete,
  });

  final String name, address, phoneNumber;
  final bool isActive;
  final VoidCallback press;
  final VoidCallback? onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: InkWell(
        onTap: press,
        borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadius)),
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: isActive
                  ? primaryColor
                  : Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: isActive ? 2 : 1,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadius)),
            boxShadow: isActive 
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] 
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? primaryColor.withValues(alpha: 0.1) : Theme.of(context).dividerColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/icons/Location.svg",
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    isActive ? primaryColor : Theme.of(context).iconTheme.color!.withValues(alpha: 0.5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? primaryColor : null,
                                ),
                          ),
                        ),
                        if (onEdit != null)
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            visualDensity: VisualDensity.compact,
                            tooltip: "Edit",
                          ),
                        if (onDelete != null)
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            visualDensity: VisualDensity.compact,
                            tooltip: "Delete",
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: Theme.of(context).disabledColor),
                        const SizedBox(width: 4),
                        Text(
                          phoneNumber,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: defaultPadding / 2),
                const Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
