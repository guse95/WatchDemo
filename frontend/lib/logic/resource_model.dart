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
    return Resource(id: json['id'], name: json['name'], type: json['type'], description: json['description']);
  }
}
