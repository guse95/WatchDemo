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
    return Resource(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      roomCapacity: int.tryParse(json['extra_attributes']['room-capacity'] ?? ""),
      roomArea: int.tryParse(json['extra_attributes']['room-area'] ?? ""),
      roomHasProjector: parseBool(json['extra_attributes']['room-has-projector']),
      roomHasScreen: parseBool(json['extra_attributes']['room-has-screen']),
      roomHasTV: parseBool(json['extra_attributes']['room-has-tv']),
      roomHasBoard: parseBool(json['extra_attributes']['room-has-board']),
      notebookOS: json['extra_attributes']['notebook-os'],
      notebookCPU: json['extra_attributes']['notebook-cpu'],
      notebookDiagonal: int.tryParse(json['extra_attributes']['notebook-diagonal'] ?? ""),
      boardType: json['extra_attributes']['board-type'],
      boardHeight: int.tryParse(json['extra_attributes']['board-height'] ?? ""),
      boardWidth: int.tryParse(json['extra_attributes']['board-width'] ?? ""),
      prjResolution: json['extra_attributes']['projector-resolution'],
      prjHdmi: parseBool(json['extra_attributes']['projector-hdmi']),
      prjDp: parseBool(json['extra_attributes']['projector-dp']),
      prjVga: parseBool(json['extra_attributes']['projector-vga']),
      prjDvi: parseBool(json['extra_attributes']['projector-dvi']),
    );
  }
}
