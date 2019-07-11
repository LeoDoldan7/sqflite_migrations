class Migration {
  String name;
  Function up;
  Function down;

  Migration(this.name, this.up, this.down);
}
