import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeliveryRegistrationScreen extends StatefulWidget {
  const DeliveryRegistrationScreen({super.key});

  @override
  State<DeliveryRegistrationScreen> createState() => _DeliveryRegistrationScreenState();
}

class _DeliveryRegistrationScreenState extends State<DeliveryRegistrationScreen> {
  String _ownerType = 'مكتب تأجير سيارات';

  void _onNextPressed() {
    if(_ownerType == 'مكتب تأجير سيارات'){
      context.push('/delivery-office-information');
    }else{
      context.push('/DeliveryPersonInformationScreen');
    }

  }

  Widget _buildRadioOption(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.right,
        ),
        value: title,
        groupValue: _ownerType,
        activeColor: Colors.orange,
        onChanged: (value) {
          setState(() {
            _ownerType = value!;
          });
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'نوعية صاحب العقار',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 20),
              _buildRadioOption('مكتب تأجير سيارات'),
              _buildRadioOption('كابتن - سائق'),
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                ),
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
