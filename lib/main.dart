import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyc_workflow/digio_config.dart';
import 'package:kyc_workflow/environment.dart';
import 'package:kyc_workflow/gateway_event.dart';
import 'package:kyc_workflow/kyc_workflow.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kyc_workflow/service_mode.dart';
import 'dart:collection';
import 'package:flutter_me/TestWebViewPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _workflowResult = '';

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Click on + button to start',
            ),
            Text(
              '$_workflowResult',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'kyc_btn',
            onPressed: startKycWorkflow,
            tooltip: 'Start KYC Workflow',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'webview_btn',
            onPressed: openTestWebView,
            tooltip: 'Open TestWebView',
            child: const Icon(Icons.web),
          ),
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: startKycWorkflow,
      //   // onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> startKycWorkflow() async {
    var workflowResult;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      var digioConfig = DigioConfig();
      digioConfig.theme.primaryColor = "#32a83a";
      digioConfig.logo =
      "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png";
      digioConfig.environment = Environment.SANDBOX;
      digioConfig.serviceMode = ServiceMode.OTP;

      final _kycWorkflowPlugin = KycWorkflow(digioConfig);
      _kycWorkflowPlugin.setGatewayEventListener((GatewayEvent? gatewayEvent) {
        print("gateway funnel event ${gatewayEvent?.event}");
      });

      HashMap<String, String> additionalData = HashMap<String, String>();
      // additionalData["dg_disable_upi_collect_flow"] = "false"; // optional for mandate

      workflowResult = await _kycWorkflowPlugin.start(
          "KID250506111813554ONRYOJ8XX2BXXXK",
          "a@digio.in",
          "GWT25050611181360747HL34EC5OXXNS",
          additionalData
      );
      print('workflowResult : ' + workflowResult.toString());
    } on PlatformException {
      workflowResult = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _workflowResult = workflowResult.toString();
    });
  }

  void openTestWebView() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TestWebViewPage(
          docId: "KID250724142028563QCOONVXXXXFI",
          identifier: "a@digio.in",
          token: "GWT2507241420285736LEOVDXXXK2GS",
          environment: "PRODUCTION",
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _workflowResult = "WebView Result:\n$result";
      });
    }
  }





  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
    ].request();

    if (statuses[Permission.camera]?.isGranted ?? false) {
      print("Camera permission granted.");
    }
    if (statuses[Permission.microphone]?.isGranted ?? false) {
      print("Microphone permission granted.");
    }
    if (statuses[Permission.location]?.isGranted ?? false) {
      print("Location permission granted.");
    }

    // Handle denied permissions if needed
    if (statuses[Permission.camera]?.isDenied ?? false) {
      print("Camera permission denied.");
    }
    if (statuses[Permission.microphone]?.isDenied ?? false) {
      print("Microphone permission denied.");
    }
    if (statuses[Permission.location]?.isDenied ?? false) {
      print("Location permission denied.");
    }
  }
}
