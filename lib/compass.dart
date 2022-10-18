import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class Compass extends StatefulWidget {
  const Compass({Key? key}) : super(key: key);

  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        if (_hasPermission) {
          return _buildCompass();
        } else {
          return _buildPermissionSheet();
        }
      }),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error heading+ ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        double? direction = snapshot.data!.heading;

        if (direction == null) {
          return Center(
            child: Text('Diveces does not have sensors'),
          );
        }
        return Center(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Transform.rotate(
                angle: direction * (math.pi / 180) * -1,
                child: Image.asset(
                  'assets/images/compas.png',
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: const Text('Уруксат бер'),
        onPressed: (() {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        }),
      ),
    );
  }
}
