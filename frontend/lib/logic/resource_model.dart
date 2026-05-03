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
  final int? notebookScreensize;

  final String? boardType;
  final int? boardHeight;
  final int? boardWidth;

  final String? projectorResolution;
  final String? projectorConnections;

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
    this.notebookScreensize,
    this.boardType,
    this.boardHeight,
    this.boardWidth,
    this.projectorResolution,
    this.projectorConnections,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(id: json['id'], name: json['name'], type: json['type'], description: json['description']);
  }
}
