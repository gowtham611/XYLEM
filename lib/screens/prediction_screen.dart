// lib/screens/prediction_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/sensor_data_provider.dart';
import '../services/ml_service.dart';
import '../services/onnx_runtime_service.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  CropPrediction? _predictionResult;
  String? _error;
  String? _ortStatus;

  final MLService _mlService = MLService();

  // Animation controllers for reveal
  late AnimationController _revealController;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;
  double _confidenceAnimTarget = 0.0;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardSlide = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutBack,
    );
    _cardFade = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _checkOnnxRuntime() async {
    setState(() {
      _loading = true;
      _ortStatus = null;
      _error = null;
    });

    try {
      final status = await OnnxRuntimeService.checkOrt();
      if (status['available'] == true) {
        setState(() {
          _ortStatus = '✅ ONNX Runtime ${status['version']} available';
        });
      } else {
        setState(() {
          _ortStatus = '❌ ONNX Runtime not available: ${status['error']}';
        });
      }
    } catch (e) {
      setState(() {
        _ortStatus = '❌ Check failed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _runPrediction(SensorData data) async {
    setState(() {
      _loading = true;
      _error = null;
      _predictionResult = null;
    });

    try {
      await _mlService.initializeModel();
      final pred = await _mlService.predictCrop(data, null);

      // Animate reveal
      setState(() {
        _predictionResult = pred;
        _confidenceAnimTarget = pred.confidence.clamp(0.0, 1.0);
      });
      _revealController.reset();
      _revealController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Start simulation and wait for data, then run prediction
  Future<void> _simulateAndRun(SensorDataProvider provider) async {
    setState(() {
      _loading = true;
      _error = null;
      _predictionResult = null;
    });

    try {
      provider.startSimulation();

      final timeout = Duration(seconds: 3);
      final pollInterval = Duration(milliseconds: 200);
      var waited = Duration.zero;

      while (provider.currentData == null && waited < timeout) {
        await Future.delayed(pollInterval);
        waited += pollInterval;
      }

      if (provider.currentData != null) {
        await _runPrediction(provider.currentData!);
      } else {
        setState(() {
          _error = 'Simulation did not produce data in time.';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // --- UI Builders ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.indigo.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(FontAwesomeIcons.brain, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Crop Advisor',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Smart crop predictions · Soil insights · Farming tips',
                  style: GoogleFonts.roboto(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _checkOnnxRuntime,
            icon: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline, color: Colors.white),
            tooltip: 'Check ONNX Runtime',
          )
        ],
      ),
    );
  }

  Widget _buildControls(SensorDataProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: _loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(FontAwesomeIcons.play),
            label: Text(_loading ? 'Running...' : 'Run AI Prediction'),
            onPressed: _loading || provider.currentData == null
                ? null
                : () => _runPrediction(provider.currentData!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.indigo,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _loading ? null : () => _simulateAndRun(provider),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            backgroundColor: Colors.green.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(
            children: const [
              Icon(FontAwesomeIcons.bolt, size: 16),
              SizedBox(width: 8),
              Text('Simulate'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedPredictionCard() {
    if (_predictionResult == null) {
      return _buildEmptyCard();
    }

    // Animated builder for the reveal
    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, _) {
        final slide = _cardSlide.value;
        final fade = _cardFade.value;

        return Opacity(
          opacity: fade,
          child: Transform.translate(
            offset: Offset(0, (1 - slide) * 40),
            child: _PredictionCardBody(
              key: ValueKey(_predictionResult!.cropName + _predictionResult!.confidence.toString()),
              prediction: _predictionResult!,
              confidenceTarget: _confidenceAnimTarget,
              animation: _revealController,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.seedling, size: 44, color: Colors.grey[500]),
              const SizedBox(height: 8),
              Text('No predictions yet', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Run the AI prediction to see results', style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus() {
    if (_error != null) {
      return Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text('Prediction error: $_error')),
            ],
          ),
        ),
      );
    }

    if (_ortStatus != null) {
      return Card(
        color: _ortStatus!.startsWith('✅') ? Colors.green[50] : Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(_ortStatus!.startsWith('✅') ? Icons.check_circle : Icons.warning,
                  color: _ortStatus!.startsWith('✅') ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text(_ortStatus!)),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatus(),
              const SizedBox(height: 12),
              _buildControls(provider),
              const SizedBox(height: 16),
              _buildAnimatedPredictionCard(),
              const SizedBox(height: 16),
              if (provider.currentData == null)
                _buildNoPredictionCard(provider),
              const SizedBox(height: 80), // Extra padding at bottom
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoPredictionCard(SensorDataProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.brain, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No Prediction Data',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text('Connect sensors or start simulation to get predictions', style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: _loading ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(FontAwesomeIcons.play),
                label: Text(_loading ? 'Starting...' : 'Simulate & Run'),
                onPressed: _loading ? null : () => _simulateAndRun(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small widget that displays the prediction details with animations.
class _PredictionCardBody extends StatefulWidget {
  final CropPrediction prediction;
  final double confidenceTarget;
  final AnimationController animation;

  const _PredictionCardBody({
    super.key,
    required this.prediction,
    required this.confidenceTarget,
    required this.animation,
  });

  @override
  State<_PredictionCardBody> createState() => _PredictionCardBodyState();
}

class _PredictionCardBodyState extends State<_PredictionCardBody> {
  late Animation<double> _confAnim;
  late Animation<double> _popAnim;

  @override
  void initState() {
    super.initState();
    _confAnim = Tween<double>(begin: 0.0, end: widget.confidenceTarget).animate(
      CurvedAnimation(parent: widget.animation, curve: const Interval(0.15, 0.8, curve: Curves.easeOut)),
    );
    _popAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: widget.animation, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );
  }

  @override
  void didUpdateWidget(covariant _PredictionCardBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confidenceTarget != widget.confidenceTarget) {
      // Recreate animation to new target
      _confAnim = Tween<double>(begin: 0.0, end: widget.confidenceTarget).animate(
        CurvedAnimation(parent: widget.animation, curve: const Interval(0.15, 0.8, curve: Curves.easeOut)),
      );
    }
  }

  String _cropEmoji(String name) {
    // small helper to map some crop names to emojis
    final n = name.toLowerCase();
    if (n.contains('rice')) return '🌾';
    if (n.contains('apple')) return '🍎';
    if (n.contains('banana')) return '🍌';
    if (n.contains('mango')) return '🥭';
    if (n.contains('tomato')) return '🍅';
    return '🌱';
  }

  @override
  Widget build(BuildContext context) {
    final pred = widget.prediction;
    final top3 = pred.top3Crops;
    final soil = pred.soilCondition;

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left: animated circular confidence gauge
            SizedBox(
              width: 140,
              height: 140,
              child: AnimatedBuilder(
                animation: widget.animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _popAnim.value,
                    child: CustomPaint(
                      painter: _RadialConfidencePainter(_confAnim.value),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${( (_confAnim.value * 100).clamp(0, 100)).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text('Confidence', style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 16),

            // Right: details
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    ScaleTransition(
                      scale: _popAnim,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_cropEmoji(pred.cropName), style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(pred.cropName.toUpperCase(), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Model recommendation', style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600])),
                    ]),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10)),
                      child: Text(pred.confidence > 0.5 ? 'Primary' : 'Advisory', style: GoogleFonts.roboto(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text("Top alternatives", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                // Top3 list
                Column(
                  children: top3.map((alt) {
                    final pct = (alt.confidence * 100).clamp(0.0, 100.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Text(alt.name, style: GoogleFonts.roboto(fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: alt.confidence,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${pct.toStringAsFixed(0)}%', style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700])),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Soil condition chips & quick tips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Soil: ${soil.overall.toUpperCase()}'), avatar: const Icon(Icons.terrain, size: 16)),
                    if (soil.issues.isNotEmpty) Chip(label: Text('${soil.issues.length} issues'), avatar: const Icon(Icons.warning, size: 16)),
                    if (soil.recommendations.isNotEmpty) Chip(label: Text('Tips'), avatar: const Icon(Icons.lightbulb, size: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                // Expandable recommendations
                ExpansionTile(
                  title: Text('View soil recommendations', style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600)),
                  children: [
                    if (soil.issues.isEmpty) Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('No major soil issues detected.', style: GoogleFonts.roboto(fontSize: 13)),
                    ),
                    ...soil.issues.map((s) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.error_outline, color: Colors.orange),
                      title: Text(s, style: GoogleFonts.roboto(fontSize: 13)),
                    )),
                    const Divider(),
                    ...soil.recommendations.map((r) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                      title: Text(r, style: GoogleFonts.roboto(fontSize: 13)),
                    )),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the radial confidence gauge
class _RadialConfidencePainter extends CustomPainter {
  final double progress; // 0.0 .. 1.0

  _RadialConfidencePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final thickness = size.width * 0.12;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) / 2) - thickness;

    // background circle
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = Colors.grey.shade200;
    canvas.drawCircle(center, radius, bgPaint);

    // gradient arc paint
    final sweep = progress.clamp(0.0, 1.0) * 2 * math.pi;
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi,
      colors: [Colors.green, Colors.yellow.shade700, Colors.orange, Colors.red],
      stops: const [0.0, 0.45, 0.75, 1.0],
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickness
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweep, false, arcPaint);

    // small center circle
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - thickness - 4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _RadialConfidencePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
