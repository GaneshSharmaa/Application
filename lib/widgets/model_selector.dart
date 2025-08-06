import 'dart:ui';
import 'package:flutter/material.dart';

class ModelSelector extends StatefulWidget {
  final Function(String) onModelSelected;
  final String selectedModel;

  const ModelSelector({
    super.key,
    required this.onModelSelected,
    required this.selectedModel,
  });

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  final List<String> models = ['Mitra', 'GPT-4', 'Claude', 'Gemini', 'Deepseek'];
  late String _currentModel;

  final Map<String, String> modelIcons = {
    'Mitra': 'assets/icon/mitra.png',  // ✅ Make sure mitra.png is in assets/icon/
    'GPT-4': 'assets/icon/gpt.png',
    'Claude': 'assets/icon/claude.png',
    'Gemini': 'assets/icon/gemini.png',
    'Deepseek': 'assets/icon/deepseek.png',
  };

  @override
  void initState() {
    super.initState();
    _currentModel = widget.selectedModel;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _currentModel,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            dropdownColor: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _currentModel = newValue);
                widget.onModelSelected(newValue);
              }
            },
            selectedItemBuilder: (BuildContext context) {
              return models.map((String model) {
                return Row(
                  children: [
                    Image.asset(
                      modelIcons[model]!,
                      height: 20,
                      width: 20,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 20, color: Colors.white54),
                    ),
                    const SizedBox(width: 6),
                    Text(model),
                  ],
                );
              }).toList();
            },
            items: models.map((String model) {
              return DropdownMenuItem<String>(
                value: model,
                child: Row(
                  children: [
                    Image.asset(
                      modelIcons[model]!,
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(model),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
