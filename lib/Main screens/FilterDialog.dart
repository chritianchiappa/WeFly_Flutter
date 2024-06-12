import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterDialog extends StatefulWidget {
  final void Function(DateTimeRange?, double, double) onApply;
  final DateTimeRange? initialDateRange;
  final double initialBudget;
  final double initialCompatibility;

  const FilterDialog({
    required this.onApply,
    this.initialDateRange,
    required this.initialBudget,
    required this.initialCompatibility,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late DateTimeRange? _selectedDateRange;
  late double _selectedBudget;
  late double _selectedCompatibility;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = widget.initialDateRange;
    _selectedBudget = widget.initialBudget;
    _selectedCompatibility = widget.initialCompatibility;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filtri'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Range Picker per selezionare la data
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.grey),
              ),
              title: Text(
                _selectedDateRange == null
                    ? 'Date'
                    : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
              ),
              leading: Icon(Icons.date_range_outlined),
              onTap: () async {
                final pickedDateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 700)),
                );

                if (pickedDateRange != null) {
                  setState(() {
                    _selectedDateRange = pickedDateRange;
                  });
                }
              },
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget massimo'),
                Text('${_selectedBudget.toStringAsFixed(2)} €'),
              ],
            ),
            Slider(
              value: _selectedBudget,
              min: 0,
              max: 10000,
              divisions: 20,
              onChanged: (newValue) {
                setState(() {
                  _selectedBudget = newValue;
                });
              },
            ),
            SizedBox(height: 10,),
            // Slider per la percentuale di compatibilità
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Compatibilità minima'),
                Text('${_selectedCompatibility.toStringAsFixed(2)} %'),
              ],
            ),
            Slider(
              value: _selectedCompatibility,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (newValue) {
                setState(() {
                  _selectedCompatibility = newValue;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onApply(_selectedDateRange, _selectedBudget, _selectedCompatibility);
            Navigator.of(context).pop();
          },
          child: Text('Applica'),
        ),
      ],
    );
  }
}