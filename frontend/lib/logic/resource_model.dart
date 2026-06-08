bool? parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;

  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return null;
}

int? parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class Resource {
  final int id;
  final String name;
  final String type;
  final String description;

  final int? roomCapacity;
  final int? roomArea;
  final bool? roomHasProjector;
  final bool? roomHasScreen;
  final bool? roomHasTV;
  final bool? roomHasBoard;

  final String? notebookOS;
  final String? notebookCPU;
  final int? notebookDiagonal;

  final String? boardType;
  final int? boardHeight;
  final int? boardWidth;

  final String? prjResolution;
  final bool? prjHdmi;
  final bool? prjDp;
  final bool? prjVga;
  final bool? prjDvi;

  Resource({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.roomCapacity,
    this.roomArea,
    this.roomHasProjector,
    this.roomHasScreen,
    this.roomHasTV,
    this.roomHasBoard,
    this.notebookOS,
    this.notebookCPU,
    this.notebookDiagonal,
    this.boardType,
    this.boardHeight,
    this.boardWidth,
    this.prjResolution,
    this.prjHdmi,
    this.prjDp,
    this.prjVga,
    this.prjDvi,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    final extraAttributes = json['extra_attributes'] is Map
        ? Map<String, dynamic>.from(json['extra_attributes'] as Map)
        : <String, dynamic>{};

    return Resource(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'] ?? '',
      roomCapacity: parseInt(extraAttributes['room-capacity']),
      roomArea: parseInt(extraAttributes['room-area']),
      roomHasProjector: parseBool(extraAttributes['room-has-projector']),
      roomHasScreen: parseBool(extraAttributes['room-has-screen']),
      roomHasTV: parseBool(extraAttributes['room-has-tv']),
      roomHasBoard: parseBool(extraAttributes['room-has-board']),
      notebookOS: extraAttributes['notebook-os'],
      notebookCPU: extraAttributes['notebook-cpu'],
      notebookDiagonal: parseInt(extraAttributes['notebook-diagonal']),
      boardType: extraAttributes['board-type'],
      boardHeight: parseInt(extraAttributes['board-height']),
      boardWidth: parseInt(extraAttributes['board-width']),
      prjResolution: extraAttributes['projector-resolution'],
      prjHdmi: parseBool(extraAttributes['projector-hdmi']),
      prjDp: parseBool(extraAttributes['projector-dp']),
      prjVga: parseBool(extraAttributes['projector-vga']),
      prjDvi: parseBool(extraAttributes['projector-dvi']),
    );
  }
}
