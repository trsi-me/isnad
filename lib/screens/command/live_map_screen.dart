import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/location_service.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report/report_map_pin.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _controller = MapController();
  LatLng? _me;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ReportProvider>().refreshReports();
      final pos = await LocationService.getCurrentLocation();
      if (!mounted) return;
      if (pos != null) {
        setState(() => _me = LatLng(pos.latitude, pos.longitude));
      }
    });
  }

  List<ReportModel> _markers(ReportProvider rp) {
    return rp.reports.where((r) {
      if (r.locationLat == null || r.locationLng == null) return false;
      if (r.isSos) return true;
      return r.status == 'open' ||
          r.status == 'responding' ||
          r.status == 'received' ||
          r.status == 'arrived';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<ReportProvider>();
    final items = _markers(rp);
    final center = _me ?? const LatLng(24.7136, 46.6753);
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundSecondary,
        title: Text('خريطة مباشرة', style: AppTextStyles.headline3),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary),
        ),
      ),
      body: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'isnad',
          ),
          MarkerLayer(
            markers: [
              if (_me != null)
                Marker(
                  point: _me!,
                  width: 36,
                  height: 36,
                  child: const Icon(Icons.my_location, color: AppColors.silverLight),
                ),
              ...items.map(
                (r) => Marker(
                  point: LatLng(r.locationLat!, r.locationLng!),
                  width: 36,
                  height: 36,
                  child: ReportMapPin(
                    color: statusPinColor(isSos: r.isSos, status: r.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'recenter',
            backgroundColor: AppColors.backgroundSecondary,
            onPressed: () async {
              final pos = await LocationService.getCurrentLocation();
              if (!mounted || pos == null) return;
              final ll = LatLng(pos.latitude, pos.longitude);
              setState(() => _me = ll);
              _controller.move(ll, 14);
            },
            child: const Icon(Icons.gps_fixed, color: AppColors.goldPrimary),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'refresh',
            backgroundColor: AppColors.goldPrimary,
            onPressed: () => context.read<ReportProvider>().refreshReports(),
            child: const Icon(Icons.refresh, color: AppColors.backgroundPrimary),
          ),
        ],
      ),
    );
  }
}
