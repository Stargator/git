class PElement extends PEventTarget{
  num width, height, _alpha;
  Size _lastDrawSize;
  bool clip = false;
  List<AffineTransform> _transforms;
  IElementParent _parent;

  PElement(int this.width, int this.height, [bool enableCache = false])
  {
    _transforms = new List();
    if(enableCache){
      // TODO: init magic here
    }
  }

  Size get size(){
    return new Size(width, height);
  }

  AffineTransform getTransform() {
    var tx = new AffineTransform();

    for(var t in _transforms){
      tx.concatenate(t);
    }
    return tx;
  }

  bool draw(CanvasRenderingContext2D ctx){
    update();
    var dirty = (_lastDrawSize == null);
    drawInternal(ctx);
    return dirty;
  }

  void update(){
    dispatchEvent('Update');
  }
  
  AffineTransform addTransform(){
    var tx = new AffineTransform();
    _transforms.add(tx);
    return tx;
  }

  // protected
  void drawCore(CanvasRenderingContext2D ctx){
    if (_alpha != null) {
      ctx.globalAlpha = _alpha;
    }

    // call the abstract draw method
    drawOverride(ctx);
    _lastDrawSize = this.size;
  }

  // abstract
  void drawOverride(CanvasRenderingContext2D ctx){
    throw "should override in subclass";
  }

  void invalidateDraw(){
    _invalidateParent();
  }
  
  bool hasVisualChild(PElement element){
    var length = visualChildCount;
    for(var i=0;i<length;i++){
      if(element === getVisualChild(i)){
        return true;
      }
    }
    return false;
  }
  
  PElement getVisualChild(int index){
    throw "no children for this type";    
  }
  
  int get visualChildCount(){
    return 0;
  }
  
  void claim(IElementParent parent) {
    assert(_parent == null);
    _parent = parent;
  }
  
  //
  // Privates
  //

  void drawInternal(CanvasRenderingContext2D ctx){
    // until we ar rocking caching, just draw normal
    _drawNormal(ctx);
  }

  void _drawNormal(CanvasRenderingContext2D ctx){
    var tx = this.getTransform();
    if (this._isClipped(tx, ctx)) {
      return;
    }

    ctx.save();

    // Translate to the starting position
    gfx.transform(ctx, tx);

    // clip to the bounds of the object
    if (this.clip) {
      ctx.beginPath();
      ctx.rect(0, 0, width, height);
      ctx.clip();
    }

    this.drawCore(ctx);
    ctx.restore();
  }

  bool _isClipped(AffineTransform tx, CanvasRenderingContext2D ctx){
    if(clip){
      // a lot more impl to do here...
    }
    return false;
  }
  
  void _invalidateParent(){
    if(_lastDrawSize != null){
        assert(this._parent != null);
      _parent.childInvalidated(this);
    }
  }
}
