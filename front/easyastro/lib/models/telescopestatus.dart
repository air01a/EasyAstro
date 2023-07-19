class TelescopeStatus {
  String currentTask;
  double ra;
  double dec;
  String object;
  bool stacking;
  double exposition;
  int lastError;
  double ccdOrientation;
  int stacked;
  int discarded;

  TelescopeStatus(
      this.currentTask,
      this.ra,
      this.dec,
      this.object,
      this.stacking,
      this.exposition,
      this.lastError,
      this.ccdOrientation,
      this.stacked,
      this.discarded);

  TelescopeStatus.fromJson(Map<String, dynamic> json)
      : currentTask = json['current_task'],
        ra = json['ra'],
        dec = json['dec'],
        object = json['object'],
        stacking = json['stacking'],
        exposition = json['exposition'],
        lastError = json['last_error'],
        ccdOrientation = json['ccd_orientation'],
        stacked = json['stacked'],
        discarded = json['discarded'];

  Map<String, dynamic> toJson() => {
        'current_task': currentTask,
        'ra': ra,
        'dec': dec,
        'object': object,
        'stacking': stacking,
        'exposition': exposition,
        'last_error': lastError,
        'ccd_orientation': ccdOrientation,
        'stacked': stacked,
        'discarded': discarded
      };
}
