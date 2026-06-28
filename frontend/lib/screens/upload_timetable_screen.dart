import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class UploadTimetableScreen extends StatefulWidget {
  const UploadTimetableScreen({super.key});

  @override
  State<UploadTimetableScreen> createState() => _UploadTimetableScreenState();
}

class _UploadTimetableScreenState extends State<UploadTimetableScreen> {
  final TextEditingController extractedTextController = TextEditingController();

  bool isLoading = false;
  bool isSaving = false;

  List geminiSchedules = [];

  Future<void> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["png", "jpg", "jpeg", "pdf"],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    setState(() {
      isLoading = true;
      geminiSchedules = [];
      extractedTextController.text = "";
    });

    final resultData = await ApiService.uploadTimetable(
      result.files.single.path!,
    );

    setState(() {
      geminiSchedules = resultData["gemini_schedules"] ?? [];
      extractedTextController.text = resultData["extracted_text"] ?? "";
      isLoading = false;
    });
  }

  Future<void> saveGeminiSchedules() async {
    if (geminiSchedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No AI schedules detected"),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final success = await ApiService.saveGeminiSchedules(
      geminiSchedules,
    );

    setState(() {
      isSaving = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("AI schedules saved successfully"),
        ),
      );

      Navigator.pop(context);
    }
  }

  Future<void> saveExtractedSchedule() async {
    if (extractedTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No timetable text to save"),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final success = await ApiService.saveExtractedSchedules(
      extractedTextController.text,
    );

    setState(() {
      isSaving = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Schedules saved successfully"),
        ),
      );

      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save schedules"),
        ),
      );
    }
  }

  void showFormatGuide() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("AI Upload Guide"),
        content: const Text(
          "Upload a clear timetable image or PDF.\n\n"
          "The AI analyzer will try to detect courses, days, times, and locations.\n\n"
          "If AI detection is incomplete, edit the raw text into this format:\n\n"
          "Monday, 08:00, Software Engineering, Software Lab\n"
          "Tuesday, 10:00, Machine Learning, Room 5",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    extractedTextController.dispose();
    super.dispose();
  }

  Widget buildUploadHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Timetable Upload",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Upload an image or PDF and let the app detect schedules for you.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : pickAndUploadFile,
        icon: const Icon(Icons.cloud_upload_outlined),
        label: Text(
          isLoading ? "Analyzing timetable..." : "Choose Image or PDF",
        ),
      ),
    );
  }

  Widget buildLoadingBox() {
    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Analyzing your timetable. This may take a few seconds...",
              style: TextStyle(
                color: Color(0xFF1D4ED8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetectedSchedulesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPanelTitle(
            icon: Icons.auto_awesome,
            title: "AI Detected Schedules",
            subtitle: "${geminiSchedules.length} detected",
          ),
          const SizedBox(height: 14),
          Expanded(
            child: geminiSchedules.isEmpty
                ? buildEmptyAiState()
                : ListView.builder(
                    itemCount: geminiSchedules.length,
                    itemBuilder: (context, index) {
                      final item = geminiSchedules[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.event_available,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["title"] ?? "Detected Class",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${item["day"] ?? "Unknown day"} • ${item["time"] ?? "Unknown time"}",
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    item["location"] ?? "Not specified",
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  geminiSchedules.isEmpty || isSaving ? null : saveGeminiSchedules,
              icon: const Icon(Icons.save_alt),
              label: Text(
                isSaving ? "Saving..." : "Save AI Schedules",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRawTextCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPanelTitle(
            icon: Icons.text_snippet_outlined,
            title: "Manual Correction",
            subtitle: "Edit OCR text if AI misses details",
          ),
          const SizedBox(height: 14),
          Expanded(
            child: TextField(
              controller: extractedTextController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                labelText: "Raw extracted timetable text",
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSaving ? null : saveExtractedSchedule,
              icon: const Icon(Icons.edit_note),
              label: Text(
                isSaving ? "Saving..." : "Save Corrected Text",
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(
                  color: Color(0xFF2563EB),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPanelTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEmptyAiState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                size: 48,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "No AI results yet",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Upload a clear timetable image or PDF to detect schedules.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPanels() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 850) {
          return Column(
            children: [
              SizedBox(
                height: 420,
                child: buildDetectedSchedulesCard(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 420,
                child: buildRawTextCard(),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: buildDetectedSchedulesCard(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: buildRawTextCard(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Upload"),
        actions: [
          IconButton(
            tooltip: "Help",
            icon: const Icon(Icons.help_outline),
            onPressed: showFormatGuide,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            buildUploadHero(),
            const SizedBox(height: 16),
            buildUploadButton(),
            const SizedBox(height: 12),
            buildLoadingBox(),
            const SizedBox(height: 16),
            Expanded(
              child: buildPanels(),
            ),
          ],
        ),
      ),
    );
  }
}