import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showThis = useState(false);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Switch(onChanged: (v) => showThis.value = v, value: showThis.value),
            if (showThis.value)
              const Text(
                'Something',
              )
            else
              ProviderScope(
                overrides: [
                  someProvider.overrideWithValue('Something else'),
                ],
                child: OverlayContainer(
                  hint: const Hint(),
                  child: ElevatedButton(
                    child: const Text('Press me!'),
                    onPressed: () {},
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OverlayContainer extends HookConsumerWidget {
  const OverlayContainer({super.key, required this.child, required this.hint});
  final Widget child;
  final Widget hint;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = useRef(LayerLink());
    useEffect(() {
      var inserted = false;
      var disposed = false;
      final overlay = OverlayEntry(builder: (c) {
        return ProviderScope(
          parent: ProviderScope.containerOf(context),
          child: Positioned(
            width: 200,
            child: CompositedTransformFollower(
              link: link.value,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              child: hint,
            ),
          ),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (!disposed) {
          print('Inserting');
          Overlay.of(context).insert(overlay);
          inserted = true;
        }
      });
      return () {
        if (inserted) {
          print('Removing overlay');
          overlay.remove();
          overlay.dispose();
        }
        disposed = true;
      };
    }, []);
    return CompositedTransformTarget(
      link: link.value,
      child: child,
    );
  }
}

class Hint extends ConsumerWidget {
  const Hint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(someProvider);
    print('Building Hint');
    return Card(child: Text(text));
  }
}

final someProvider = Provider((ref) => 'Something');
