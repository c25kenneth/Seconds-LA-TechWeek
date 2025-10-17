import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:replate/home/ListingInfoPage.dart';

class BuyerHome extends StatefulWidget {
  const BuyerHome({super.key});

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _sortBy = 'Newest';
  String _statusFilter = 'All';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Available":
        return const Color(0xFF4CAF50);
      case "Reserved":
        return const Color(0xFFFFB300);
      case "Donated":
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  List<Map<String, dynamic>> _applyLocalFilters(List<QueryDocumentSnapshot> docs) {
    final q = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> results = docs.map((d) {
      final data = d.data() as Map<String, dynamic>;

      return {
        'id': d.id,
        'title': (data['title'] ?? '') as String,
        'quantity': (data['quantity'] ?? '') as String,
        'currentStatus': (data['currentStatus'] ?? data['status'] ?? 'Available') as String,
        'expirationDate': (data['expirationDate'] ?? '') as String,
        'imageUrl': (data['imageUrl'] ?? '') as String,
        'listingAdded': data['listingAdded'],
        'pickupLocation': (data['pickupLocation'] ?? '') as String,
        'qualityScore': (data['qualityScore'] ?? '') as String,
        'additionalNotes': (data['additionalNotes'] ?? '') as String,
        'supplierUID': (data['supplierUID'] ?? '') as String,
      };
    }).toList();

    if (q.isNotEmpty) {
      results = results.where((item) {
        final title = (item['title'] as String).toLowerCase();
        final notes = (item['additionalNotes'] as String).toLowerCase();
        return title.contains(q) || notes.contains(q);
      }).toList();
    }

    if (_statusFilter != 'All') {
      results = results.where((r) => (r['currentStatus'] ?? '') == _statusFilter).toList();
    }


    if (_sortBy == 'Newest') {
      results.sort((a, b) {
        final ta = a['listingAdded'];
        final tb = b['listingAdded'];
        if (ta is Timestamp && tb is Timestamp) {
          return tb.compareTo(ta);
        }
        return 0;
      });
    } else if (_sortBy == 'Quality') {
      results.sort((a, b) {

        int qa = int.tryParse((a['qualityScore'] as String).split('/').first) ?? 0;
        int qb = int.tryParse((b['qualityScore'] as String).split('/').first) ?? 0;
        return qb.compareTo(qa);
      });
    }

    return results;
  }

  Widget _listingCard(Map<String, dynamic> item) {
    final status = item['currentStatus'] as String? ?? 'Available';
    final color = _statusColor(status);
    final imageUrl = (item['imageUrl'] as String?) ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {

        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // image
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
                        ),
                      )
                    : const Center(child: Icon(Icons.image, color: Colors.white30)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String? ?? 'No title',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quantity: ${item['quantity'] ?? "N/A"} • Exp: ${item['expirationDate'] ?? "N/A"}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: color, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if ((item['qualityScore'] ?? '').toString().isNotEmpty)
                          Text(
                            'Quality: ${item['qualityScore']}',
                            style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => FoodListingDetailPage(
                    supplierId: item["supplierUID"],
                                      availability: item["currentStatus"],
                                      edibilityScore: item["qualityScore"] ?? "N/A",
                                      title: item["title"] ?? "No Title",
                                      imageURL: item["imageUrl"] ?? "",
                                      tags: [], 
                                      quantity: item["quantity"] ?? "N/A",
                                      expirationDate: item["expirationDate"] ?? "N/A",
                                      pickupLocation: item["pickupLocation"] ?? "N/A",
                                      price: item["price"] ?? "N/A",
                                      notes: item["additionalNotes"] ?? "",
                  )));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Colors.teal.shade700;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Discover'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() {
                _sortBy = v;
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'Newest', child: Text('Newest')),
              const PopupMenuItem(value: 'Quality', child: Text('Quality')),
            ],
            icon: Icon(Icons.sort, color: accent),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() {
                _statusFilter = v;
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Available', child: Text('Available')),
              const PopupMenuItem(value: 'Reserved', child: Text('Reserved')),
              const PopupMenuItem(value: 'Donated', child: Text('Donated')),
            ],
            icon: Icon(Icons.filter_list, color: accent),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('listings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final filtered = _applyLocalFilters(docs);

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // search
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.black38),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search by title or notes',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  child: const Icon(Icons.close, size: 18, color: Colors.black45),
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${filtered.length} results', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off, size: 52, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text('No listings found', style: TextStyle(color: Colors.grey.shade600)),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _statusFilter = 'All';
                                    });
                                  },
                                  child: const Text('Clear filters'),
                                )
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, i) => _listingCard(filtered[i]),
                          ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
