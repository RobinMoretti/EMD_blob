
ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<BodyPart> otherBodyParts = new ArrayList<BodyPart>();

void setup() {
    size(512, 512);
    
    // PVector blobPosition = new PVector();
    // blobPosition.x = random(width);
    // blobPosition.y = random(width);
    
    // PVector blobVelocity = PVector.random2D();
    // blobVelocity.mult(2);
    // blobs.add(new Blob(blobPosition, blobVelocity, null));
}

void draw() {
    background(255);
    
    for(int i = 0; i < blobs.size(); i++){
        blobs.get(i).update();
        blobs.get(i).draw();
    }

    for(int i = 0; i < otherBodyParts.size(); i++){
        otherBodyParts.get(i).draw();
    }
}

void mousePressed() {
    // detect left click
    if (mouseButton == LEFT) {
        // add a new blob to mouse position
        PVector blobPosition = new PVector();
        blobPosition.x = mouseX;
        blobPosition.y = mouseY;

        PVector blobVelocity = PVector.random2D();
        blobVelocity.mult(2);

        blobs.add(new Blob(blobPosition, blobVelocity, null));
        return;
    }
    
    if (mouseButton == RIGHT) {
        // add other body part to mouse position
        PVector bodyPartPosition = new PVector();
        bodyPartPosition.x = mouseX;
        bodyPartPosition.y = mouseY;
        otherBodyParts.add(new BodyPart(bodyPartPosition, random(5, 10)));
    }

}
