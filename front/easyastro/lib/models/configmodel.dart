class ConfigItem {
  final String name;
  final String description;
  final String type;
  dynamic value;
  dynamic attributes;

  ConfigItem(this.name, this.description, this.type, this.value, this.attributes);

  ConfigItem.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        type = json['type'],
        value = json['value'],
        attributes = json['attributes'];
        

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'type' : type,
        'value' : value,
        'attributes' : attributes,
      };

}