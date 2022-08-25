void onInit(CBlob@ this){
    getMap().AddMarker(this.getPosition(), "zombie spawn");
    this.Tag("invincible");
}