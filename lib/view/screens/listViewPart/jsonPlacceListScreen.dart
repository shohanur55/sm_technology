import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sm_technology/controller/screenController/jsonPlacerListScreenController.dart';

class JsonplacerListScreen extends StatelessWidget {
  JsonplacerListScreen({super.key});

  final JsonPlacerListScreenController controller =
  Get.put(JsonPlacerListScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JsonPlacer List"),
        leading: Obx(
              () => controller.controller.isConnected.value
              ? const SizedBox.shrink()
              : const Icon(
            Icons.network_cell_outlined,
            color: Colors.red,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: () async {
            await controller.getJsonDataList();
          },
          child: controller.response.value!.isEmpty
              ? const Center(child: Text("No data found"))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            itemCount: controller.response.value?.length,
            itemBuilder: (context, index) {
              final res = controller.response.value![index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ID: ${res.id}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "User: ${res.userId}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        res.title.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        res.body.toString().replaceAll(RegExp(r'\s+'), ' '),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          height: 1.2, // Line height (optional, for better spacing)
                        ),
                        textAlign: TextAlign.justify, // For paragraph alignment
                        softWrap: true, // Ensures text wraps within boundaries
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
