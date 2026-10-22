import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'browser/browser.dart' as browser;
import 'browser/preview.dart';
import 'theme/frequency_theme.dart';
import 'tool_logic.dart';

class FrequencyTools extends StatefulWidget {
  const FrequencyTools({super.key});
  @override
  State<FrequencyTools> createState() => _FrequencyToolsState();
}

class _FrequencyToolsState extends State<FrequencyTools> {
  int selected = 0;
  // Keep tool state when the responsive shell reparents the workbench.
  final GlobalKey workbenchKey = GlobalKey();
  static const names = ['图片尺寸', '格式转换', '编码解码', '颜色工作台', 'HTML / CSS'];
  static const icons = [
    Icons.photo_size_select_large_rounded,
    Icons.transform_rounded,
    Icons.code_rounded,
    Icons.palette_outlined,
    Icons.web_rounded,
  ];
  static const descriptions = [
    '调整宽高与比例',
    'PNG / JPEG / WebP / ICO',
    'Base64 与 URL 转换',
    'HEX / RGB / HSL',
    '即时查看页面效果',
  ];
  Widget navigation(bool compact) => compact
      ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              names.length,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(names[i]),
                  selected: selected == i,
                  onSelected: (_) => setState(() => selected = i),
                ),
              ),
            ),
          ),
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                '选择一个工具',
                style: TextStyle(fontSize: 12, color: FrequencyPalette.muted),
              ),
            ),
            for (var i = 0; i < names.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  selected: selected == i,
                  selectedTileColor: FrequencyPalette.selected,
                  selectedColor: FrequencyPalette.accent,
                  iconColor: FrequencyPalette.muted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  leading: Icon(icons[i], size: 21),
                  title: Text(
                    names[i],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    descriptions[i],
                    style: const TextStyle(
                      fontSize: 11,
                      color: FrequencyPalette.muted,
                    ),
                  ),
                  onTap: () => setState(() => selected = i),
                ),
              ),
          ],
        );
  Widget workbench(BuildContext context) => Material(
    key: workbenchKey,
    color: FrequencyPalette.surface,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: FrequencyPalette.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Visibility(
            visible: selected < 2,
            maintainState: true,
            child: ExcludeFocus(
              excluding: selected >= 2,
              child: ImageWorkbench(resize: selected == 0),
            ),
          ),
          Visibility(
            visible: selected == 2,
            maintainState: true,
            child: ExcludeFocus(
              excluding: selected != 2,
              child: const TextWorkbench(),
            ),
          ),
          Visibility(
            visible: selected == 3,
            maintainState: true,
            child: ExcludeFocus(
              excluding: selected != 3,
              child: const ColorWorkbench(),
            ),
          ),
          Visibility(
            visible: selected == 4,
            maintainState: true,
            child: ExcludeFocus(
              excluding: selected != 4,
              child: const CssWorkbench(),
            ),
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        '频率工具台',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Text(
              '本机处理',
              style: TextStyle(color: FrequencyPalette.muted, fontSize: 12),
            ),
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1380),
          child: Padding(
            padding: MediaQuery.sizeOf(context).width < 700
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 900;
                final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 20,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: const [
                        Text(
                          '从一件小事开始。',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'FREQUENCY / WORKBENCH',
                          style: TextStyle(
                            color: FrequencyPalette.muted,
                            fontSize: 11,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (compact) ...[
                      navigation(true),
                      const SizedBox(height: 16),
                    ],
                    workbench(context),
                    const SizedBox(height: 18),
                    const Text(
                      '图片、文本与代码在当前浏览器中处理。下载结果保存在本机。',
                      style: TextStyle(
                        color: FrequencyPalette.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
                if (compact) return content;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 220, child: navigation(false)),
                    const SizedBox(width: 28),
                    Expanded(child: content),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

class ImageWorkbench extends StatefulWidget {
  final bool resize;
  const ImageWorkbench({super.key, required this.resize});
  @override
  State<ImageWorkbench> createState() => _ImageWorkbenchState();
}

class _ImageWorkbenchState extends State<ImageWorkbench> {
  Map<String, dynamic>? source, output;
  String? originalData, convertedData;
  ImageProvider<Object>? originalProvider, convertedProvider;
  final width = TextEditingController(),
      height = TextEditingController(),
      background = TextEditingController(text: '#FFFFFF');
  String format = 'png', error = '', status = '';
  bool busy = false, locked = true;
  double quality = 0.92;
  @override
  void dispose() {
    originalProvider?.evict();
    convertedProvider?.evict();
    width.dispose();
    height.dispose();
    background.dispose();
    super.dispose();
  }

  void invalidate() => setState(() {
    output = null;
    status = '';
  });
  Future<void> pick() async {
    setState(() {
      busy = true;
      error = '';
      status = '';
    });
    try {
      final data =
          jsonDecode(await browser.pickImage()) as Map<String, dynamic>;
      if (!mounted) return;
      if (data['error'] != null) throw FormatException(data['error'] as String);
      if (data['cancelled'] != true)
        setState(() {
          source = data;
          output = null;
          width.text = '${data['width']}';
          height.text = '${data['height']}';
        });
    } catch (e) {
      if (mounted)
        setState(
          () => error = e is FormatException ? e.message : '无法选择图片，请重试。',
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void sizeChanged(bool isWidth, String value) {
    if (locked && source != null && format != 'ico') {
      final n = int.tryParse(value);
      if (n != null && n > 0) {
        if (isWidth) {
          height.text =
              '${(n * (source!['height'] as num) / (source!['width'] as num)).round()}';
        } else {
          width.text =
              '${(n * (source!['width'] as num) / (source!['height'] as num)).round()}';
        }
      }
    }
    invalidate();
  }

  Future<void> convert() async {
    setState(() {
      busy = true;
      error = '';
      status = '';
      output = null;
    });
    try {
      final w = int.tryParse(width.text), h = int.tryParse(height.text);
      if (w == null || h == null || w < 1 || h < 1)
        throw const FormatException('宽高必须是正整数。');
      if (format == 'jpeg' &&
          !RegExp(r'^#[a-fA-F0-9]{6}$').hasMatch(background.text))
        throw const FormatException('JPEG 底色请输入 6 位 HEX，例如 #FFFFFF。');
      final result =
          jsonDecode(
                await browser.convertImage(
                  jsonEncode({
                    'data': source!['data'],
                    'width': w,
                    'height': h,
                    'format': format,
                    'background': background.text,
                    'quality': quality,
                  }),
                ),
              )
              as Map<String, dynamic>;
      if (!mounted) return;
      if (result['error'] != null)
        throw FormatException(result['error'] as String);
      setState(() {
        output = result;
        status = '转换完成 · ${(result['bytes'] as num) / 1024 ~/ 1} KB';
      });
    } catch (e) {
      if (mounted)
        setState(
          () => error = e is FormatException ? e.message : '转换失败，请重新选择图片。',
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget preview(
    String title,
    String? data,
    String detail, {
    bool converted = false,
  }) {
    final image = converted ? output : source;
    final w = (image?['width'] as num?)?.toDouble() ?? 1,
        h = (image?['height'] as num?)?.toDouble() ?? 1;
    final scale = math.min(1.0, math.min(1200 / w, 480 / h));
    if (data != (converted ? convertedData : originalData)) {
      final previous = converted ? convertedProvider : originalProvider;
      previous?.evict();
      final next = data == null
          ? null
          : ResizeImage(
              MemoryImage(base64Decode(data.split(',').last)),
              width: math.max(1, (w * scale).round()),
              height: math.max(1, (h * scale).round()),
            );
      if (converted) {
        convertedData = data;
        convertedProvider = next;
      } else {
        originalData = data;
        originalProvider = next;
      }
    }
    final provider = converted ? convertedProvider : originalProvider;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: FrequencyPalette.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: provider == null
              ? const Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: FrequencyPalette.muted,
                )
              : Image(
                  image: provider,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text('无法预览图片'),
                ),
        ),
        const SizedBox(height: 8),
        Text(detail, style: const TextStyle(color: FrequencyPalette.muted)),
      ],
    );
  }

  Widget step(String number, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: FrequencyPalette.accent,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
  void download() {
    try {
      final stem = (source!['name'] as String).replaceFirst(
        RegExp(r'\.[^.]+$'),
        '',
      );
      browser.downloadImage(
        jsonEncode({
          'data': output!['data'],
          'name':
              '$stem-${output!['width']}x${output!['height']}.${output!['format'] == 'jpeg' ? 'jpg' : output!['format']}',
        }),
      );
      setState(() => status = '已交给浏览器下载');
    } catch (_) {
      setState(() => error = '无法下载，请重试。');
    }
  }

  Widget inputPane({bool dense = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      step('01', '选择本地图片'),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: busy ? null : pick,
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(source == null ? '选择图片' : '更换图片'),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        source == null
            ? '支持常见图片格式，文件保留在你的浏览器。'
            : '${source!['name']} · ${source!['width']} × ${source!['height']}',
        style: const TextStyle(color: FrequencyPalette.muted, fontSize: 12),
      ),
      if (source != null && !dense) ...[
        const SizedBox(height: 16),
        preview('原图', source?['data'] as String?, ''),
      ],
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Divider(height: 1),
      ),
      step('02', '调整输出参数'),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: width,
              enabled: !busy && source != null,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '宽度 / px'),
              onChanged: (v) => sizeChanged(true, v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: height,
              enabled: !busy && source != null,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '高度 / px'),
              onChanged: (v) => sizeChanged(false, v),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        initialValue: format,
        isExpanded: true,
        decoration: const InputDecoration(labelText: '输出格式'),
        items: ['png', 'jpeg', 'webp', 'ico']
            .map(
              (v) => DropdownMenuItem(value: v, child: Text(v.toUpperCase())),
            )
            .toList(),
        onChanged: busy
            ? null
            : (v) {
                setState(() {
                  format = v!;
                  output = null;
                  status = '';
                  if (format == 'ico') {
                    width.text = '256';
                    height.text = '256';
                  }
                });
              },
      ),
      if (format != 'ico')
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('锁定原图比例', style: TextStyle(fontSize: 14)),
          value: locked,
          onChanged: busy ? null : (v) => setState(() => locked = v!),
        ),
      if (format == 'ico')
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'ICO 支持 16 / 32 / 48 / 64 / 128 / 256 px 正方形。',
            style: TextStyle(color: FrequencyPalette.muted, fontSize: 12),
          ),
        ),
      if (format == 'jpeg')
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: TextField(
            controller: background,
            decoration: const InputDecoration(labelText: '透明区域底色 / HEX'),
            onChanged: (_) => invalidate(),
          ),
        ),
      if (format == 'jpeg' || format == 'webp')
        Row(
          children: [
            const Text('质量', style: TextStyle(fontSize: 13)),
            Expanded(
              child: Slider(
                value: quality,
                min: 0.1,
                max: 1,
                divisions: 90,
                label: '${(quality * 100).round()}%',
                onChanged: busy
                    ? null
                    : (v) => setState(() {
                        quality = v;
                        output = null;
                        status = '';
                      }),
              ),
            ),
            Text(
              '${(quality * 100).round()}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Divider(height: 1),
      ),
      step('03', '生成图片'),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: busy || source == null ? null : convert,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.tune_rounded),
          label: Text(busy ? '处理中…' : '生成图片'),
        ),
      ),
      if (source == null)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            '先选择一张图片，再生成结果。',
            style: TextStyle(color: FrequencyPalette.muted, fontSize: 12),
          ),
        ),
      if (error.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(
              error,
              style: const TextStyle(color: FrequencyPalette.error),
            ),
          ),
        ),
      if (status.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(
              status,
              style: const TextStyle(color: FrequencyPalette.success),
            ),
          ),
        ),
    ],
  );
  Widget resultPane({bool dense = false}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: FrequencyPalette.background,
      border: Border.all(color: FrequencyPalette.border),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        step('04', '预览与下载'),
        if (source != null && dense)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('查看原图', style: TextStyle(fontSize: 13)),
            children: [preview('原图', source?['data'] as String?, '')],
          ),
        preview(
          '导出预览',
          output?['preview'] as String?,
          output == null
              ? '生成后在这里检查尺寸、格式与效果。'
              : '${output!['format'].toString().toUpperCase()} · ${output!['width']} × ${output!['height']} · ${(output!['bytes'] as num) / 1024 ~/ 1} KB',
          converted: true,
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: output == null || busy ? null : download,
            icon: const Icon(Icons.download_rounded),
            label: const Text('下载图片'),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '修改参数后，请重新生成图片。',
          style: TextStyle(fontSize: 12, color: FrequencyPalette.muted),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.resize ? '图片尺寸调整' : '图片格式转换',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text(
        '单张图片 · 最大 32 MB / 1600 万像素 · 动图导出为静态图',
        style: TextStyle(color: FrequencyPalette.muted, fontSize: 12),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Divider(height: 1),
      ),
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [inputPane(), const SizedBox(height: 24), resultPane()],
            );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: inputPane(dense: true)),
              const SizedBox(width: 28),
              Expanded(child: resultPane(dense: true)),
            ],
          );
        },
      ),
    ],
  );
}

class TextWorkbench extends StatefulWidget {
  const TextWorkbench({super.key});
  @override
  State<TextWorkbench> createState() => _TextWorkbenchState();
}

class _TextWorkbenchState extends State<TextWorkbench> {
  final input = TextEditingController(), result = TextEditingController();
  String kind = 'Base64', error = '';
  bool decode = false;
  @override
  void initState() {
    super.initState();
    result.addListener(refresh);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    result.removeListener(refresh);
    input.dispose();
    result.dispose();
    super.dispose();
  }

  void run() {
    try {
      if (utf8.encode(input.text).length > 1024 * 1024)
        throw const FormatException('文本超过 1 MB，请缩短输入。');
      result.text = transformText(input.text, kind, decode);
      setState(() => error = '');
    } catch (e) {
      result.clear();
      setState(
        () => error = e is FormatException ? '输入格式无效：${e.message}' : '转换失败',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '编码 / 解码',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text(
        'UTF-8 文本，正确保留中文与 emoji。',
        style: TextStyle(color: FrequencyPalette.muted),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 240,
            child: DropdownButton<String>(
              value: kind,
              isExpanded: true,
              itemHeight: null,
              items: [
                'Base64',
                'URL component',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() {
                kind = v!;
                result.clear();
              }),
            ),
          ),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('编码')),
              ButtonSegment(value: true, label: Text('解码')),
            ],
            selected: {decode},
            onSelectionChanged: (v) => setState(() {
              decode = v.first;
              result.clear();
            }),
          ),
        ],
      ),
      const SizedBox(height: 20),
      TextField(
        controller: input,
        maxLines: 7,
        decoration: const InputDecoration(labelText: '输入文本'),
        onChanged: (_) {
          result.clear();
          if (error.isNotEmpty) setState(() => error = '');
        },
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          FilledButton(onPressed: run, child: const Text('转换文本')),
          OutlinedButton(
            onPressed: result.text.isEmpty
                ? null
                : () {
                    input.text = result.text;
                    result.clear();
                    setState(() => decode = !decode);
                  },
            child: const Text('交换并切换方向'),
          ),
          TextButton(
            onPressed: () {
              input.clear();
              result.clear();
              setState(() => error = '');
            },
            child: const Text('清空'),
          ),
        ],
      ),
      const SizedBox(height: 20),
      TextField(
        controller: result,
        readOnly: true,
        maxLines: 7,
        decoration: const InputDecoration(labelText: '转换结果'),
      ),
      TextButton.icon(
        onPressed: result.text.isEmpty
            ? null
            : () => copyText(context, result.text),
        icon: const Icon(Icons.copy_rounded),
        label: const Text('复制结果'),
      ),
      if (error.isNotEmpty)
        Text(error, style: const TextStyle(color: FrequencyPalette.error)),
    ],
  );
}

Future<void> copyText(BuildContext context, String value) async {
  try {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已复制')));
  } catch (_) {
    if (context.mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('复制失败，请手动选择文本复制。')));
  }
}

class ColorWorkbench extends StatefulWidget {
  const ColorWorkbench({super.key});
  @override
  State<ColorWorkbench> createState() => _ColorWorkbenchState();
}

class _ColorWorkbenchState extends State<ColorWorkbench> {
  List<int> values = [214, 239, 54, 255];
  final hex = TextEditingController(text: '#D6EF36FF');
  String error = '';
  @override
  void dispose() {
    hex.dispose();
    super.dispose();
  }

  Color get color => Color.fromARGB(values[3], values[0], values[1], values[2]);
  void update() {
    try {
      final v = parseHexColor(hex.text);
      setState(() {
        values = v;
        error = '';
      });
    } catch (e) {
      setState(() => error = (e as FormatException).message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final alpha = (values[3] / 255).toStringAsFixed(5);
    final rgb = values[3] == 255
        ? 'rgb(${values.take(3).join(', ')})'
        : 'rgba(${values.take(3).join(', ')}, $alpha)';
    final components =
        '${hsl.hue.toStringAsFixed(1)}, ${(hsl.saturation * 100).toStringAsFixed(2)}%, ${(hsl.lightness * 100).toStringAsFixed(2)}%';
    final hslText = values[3] == 255
        ? 'hsl($components)'
        : 'hsla($components, $alpha)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '颜色工作台',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),
        Container(
          height: 150,
          width: double.infinity,
          color: color,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(12),
            color: FrequencyPalette.background,
            child: Text(colorHex(values)),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: hex,
          decoration: InputDecoration(
            labelText: 'HEX / RRGGBB 或 RRGGBBAA',
            errorText: error.isEmpty ? null : error,
          ),
          onSubmitted: (_) => update(),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: update, child: const Text('应用颜色')),
        for (var i = 0; i < 4; i++)
          Row(
            children: [
              SizedBox(width: 30, child: Text(['R', 'G', 'B', 'A'][i])),
              Expanded(
                child: Slider(
                  value: values[i].toDouble(),
                  max: 255,
                  divisions: 255,
                  label: '${values[i]}',
                  onChanged: (v) => setState(() {
                    values[i] = v.round();
                    hex.text = colorHex(values);
                    error = '';
                  }),
                ),
              ),
              SizedBox(width: 36, child: Text('${values[i]}')),
            ],
          ),
        SelectableText(
          '$rgb\n$hslText\n透明度 ${(values[3] / 255 * 100).round()}%',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () => copyText(context, colorHex(values)),
              icon: const Icon(Icons.copy),
              label: const Text('复制 HEX'),
            ),
            OutlinedButton(
              onPressed: () => copyText(context, rgb),
              child: const Text('复制 RGB'),
            ),
            OutlinedButton(
              onPressed: () => copyText(context, hslText),
              child: const Text('复制 HSL'),
            ),
          ],
        ),
      ],
    );
  }
}

const cssSample =
    '''<!doctype html><html><head><style>body{font-family:system-ui;background:#111315;color:#f4f2e9;padding:32px}article{border:1px solid #41484b;padding:24px;border-radius:12px}h1{color:#d6ef36}button{background:#ffb23f;border:0;padding:12px 20px;border-radius:8px}</style></head><body><article><h1>你好，频率站。</h1><p>试着修改颜色、间距与文字。</p><button>一小步，一点变化</button></article></body></html>''';

class CssWorkbench extends StatefulWidget {
  const CssWorkbench({super.key});
  @override
  State<CssWorkbench> createState() => _CssWorkbenchState();
}

class _CssWorkbenchState extends State<CssWorkbench> {
  final input = TextEditingController(text: cssSample);
  String code = cssSample, error = '';
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'HTML / CSS 预览',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text(
        '隔离预览：脚本与外网资源不执行。支持内联样式与 data 图片。',
        style: TextStyle(color: FrequencyPalette.muted),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: input,
        maxLines: 12,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        decoration: const InputDecoration(labelText: 'HTML / CSS 源码'),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        children: [
          FilledButton.icon(
            onPressed: () {
              if (input.text.length > 1024 * 1024) {
                setState(() => error = '代码超过 1 MB，请缩短。');
                return;
              }
              setState(() {
                code = input.text;
                error = '';
              });
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('更新预览'),
          ),
          TextButton(
            onPressed: () => setState(() {
              input.text = cssSample;
              code = cssSample;
              error = '';
            }),
            child: const Text('恢复示例'),
          ),
        ],
      ),
      if (error.isNotEmpty)
        Text(error, style: const TextStyle(color: FrequencyPalette.error)),
      const SizedBox(height: 20),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(height: 400, child: SafePreview(code: code)),
      ),
    ],
  );
}
