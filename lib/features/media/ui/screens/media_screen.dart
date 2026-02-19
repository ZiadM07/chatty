import 'package:chatty/core/constants/exports.dart';

@RoutePage()
class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: true,
      title: context.locale.media,
      body: Column(children: [Text('Media')]),
    );
  }
}
