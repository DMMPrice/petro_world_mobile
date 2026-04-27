import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

enum OrderStatus {
  ordered,
  processing,
  packed,
  shipped,
  delivered,
  canceled,
  returned,
  awaitingPayment,
}

class OrderStatusTracker extends StatelessWidget {
  const OrderStatusTracker({
    super.key,
    required this.status,
  });

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.canceled) {
      return _buildCanceledTracker(context);
    } else if (status == OrderStatus.returned) {
      return _buildReturnedTracker(context);
    } else if (status == OrderStatus.awaitingPayment) {
      return _buildAwaitingPaymentTracker(context);
    }

    int currentStep = 0;
    switch (status) {
      case OrderStatus.ordered:
        currentStep = 0;
        break;
      case OrderStatus.processing:
        currentStep = 1;
        break;
      case OrderStatus.packed:
        currentStep = 2;
        break;
      case OrderStatus.shipped:
        currentStep = 3;
        break;
      case OrderStatus.delivered:
        currentStep = 4;
        break;
      default:
        currentStep = 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(context, "Ordered", 0, currentStep),
        _buildLine(context, 0, currentStep),
        _buildStep(context, "Processing", 1, currentStep),
        _buildLine(context, 1, currentStep),
        _buildStep(context, "Packed", 2, currentStep),
        _buildLine(context, 2, currentStep),
        _buildStep(context, "Shipped", 3, currentStep),
        _buildLine(context, 3, currentStep),
        _buildStep(context, "Delivered", 4, currentStep),
      ],
    );
  }

  Widget _buildStep(BuildContext context, String title, int stepIndex, int currentStep) {
    bool isCompleted = stepIndex < currentStep;
    bool isActive = stepIndex == currentStep;
    bool isPending = stepIndex > currentStep;

    Color color;
    if (isCompleted || isActive) {
      color = successColor;
    } else {
      color = Theme.of(context).disabledColor.withOpacity(0.2);
    }

    return Column(
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : (isActive
                  ? Center(
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: (isCompleted || isActive)
                ? Theme.of(context).textTheme.bodyLarge!.color
                : Theme.of(context).disabledColor,
            fontWeight: (isCompleted || isActive) ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(BuildContext context, int stepIndex, int currentStep) {
    bool isCompleted = stepIndex < currentStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isCompleted ? successColor : Theme.of(context).disabledColor.withOpacity(0.2),
      ),
    );
  }

  Widget _buildCanceledTracker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(context, "Ordered", 0, 1),
        _buildLine(context, 0, 1),
        _buildCanceledStep(context, "Canceled"),
      ],
    );
  }

  Widget _buildCanceledStep(BuildContext context, String title) {
    return Column(
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: const BoxDecoration(
            color: errorColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReturnedTracker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(context, "Delivered", 0, 1),
        _buildLine(context, 0, 1),
        _buildReturnedStep(context, "Returned"),
      ],
    );
  }

  Widget _buildReturnedStep(BuildContext context, String title) {
    return Column(
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: const BoxDecoration(
            color: warningColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.keyboard_return, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAwaitingPaymentTracker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStep(context, "Ordered", 0, 0),
        _buildLine(context, 0, -1),
        _buildAwaitingPaymentStep(context, "Awaiting Payment"),
      ],
    );
  }

  Widget _buildAwaitingPaymentStep(BuildContext context, String title) {
    return Column(
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: const BoxDecoration(
            color: warningColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.payment, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
