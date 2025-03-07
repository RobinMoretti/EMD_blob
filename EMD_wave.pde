
ArrayList<Blob> blobs = new ArrayList<Blob>();

void setup() {
    size(512, 512);
    
    PVector blobPosition = new PVector();
    blobPosition.x = random(width);
    blobPosition.y = random(width);
    
    PVector blobVelocity = PVector.random2D();
    blobVelocity.mult(2);
    blobs.add(new Blob(blobPosition, blobVelocity, null));
}

void draw() {
    background(255);
    
    for(int i = 0; i < blobs.size(); i++){
        blobs.get(i).update();
        blobs.get(i).draw();
    }
}

void mousePressed() {
}
