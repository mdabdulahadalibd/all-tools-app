import 'package:flutter/material.dart';
import '../../../../common/widgets/responsive_container.dart';

class FuelMileageScreen extends StatefulWidget {
  const FuelMileageScreen({super.key});

  @override
  State<FuelMileageScreen> createState() => _FuelMileageScreenState();
}

class _FuelMileageScreenState extends State<FuelMileageScreen> {
  final TextEditingController _distanceKmCtrl = TextEditingController(text: '350');
  final TextEditingController _mileageKmLCtrl = TextEditingController(text: '14');
  final TextEditingController _fuelPriceCtrl = TextEditingController(text: '130');

  double _totalFuelLiters = 0.0;
  double _totalTripCost = 0.0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double dist = double.tryParse(_distanceKmCtrl.text) ?? 0;
    double mileage = double.tryParse(_mileageKmLCtrl.text) ?? 1;
    double price = double.tryParse(_fuelPriceCtrl.text) ?? 0;

    if (dist <= 0 || mileage <= 0) return;

    double liters = dist / mileage;
    double cost = liters * price;

    setState(() {
      _totalFuelLiters = liters;
      _totalTripCost = cost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuel Cost & Mileage Calculator')),
      body: ResponsiveContainer(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.deepOrange.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Total Estimated Trip Fuel Cost', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '৳ ${_totalTripCost.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Text(
                      'Required Fuel: ${_totalFuelLiters.toStringAsFixed(2)} Liters',
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _distanceKmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Trip Distance (km)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _mileageKmLCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Vehicle Mileage Average (km/Liter)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fuelPriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fuel Price per Liter (৳)', border: OutlineInputBorder()),
                      onChanged: (_) => _calculate(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
