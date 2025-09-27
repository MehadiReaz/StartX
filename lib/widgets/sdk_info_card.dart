import 'package:flutter/material.dart';
import '../services/flutter_sdk_service.dart';

class SdkInfoCard extends StatefulWidget {
  final String sdkPath;
  final VoidCallback? onRemove;

  const SdkInfoCard({super.key, required this.sdkPath, this.onRemove});

  @override
  State<SdkInfoCard> createState() => _SdkInfoCardState();
}

class _SdkInfoCardState extends State<SdkInfoCard> {
  Map<String, String>? _sdkInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSdkInfo();
  }

  Future<void> _loadSdkInfo() async {
    final info = await FlutterSdkService.getFlutterInfo(widget.sdkPath);
    if (mounted) {
      setState(() {
        _sdkInfo = info;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flutter SDK',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.sdkPath,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: widget.onRemove,
                    tooltip: 'Remove SDK Path',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Loading SDK information...'),
                ],
              )
            else if (_sdkInfo != null) ...[
              _buildInfoRow('Version', _sdkInfo!['version']!),
              _buildInfoRow('Channel', _sdkInfo!['channel']!),
              _buildInfoRow('Dart', _sdkInfo!['dart']!),
            ] else
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Unable to load SDK information',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
