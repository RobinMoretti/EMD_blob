
ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<BodyPart> otherBodyParts = new ArrayList<BodyPart>();
int opacityCount = 0;
boolean usePixelEffect = true;

PFont interTight;


void setup() {
    size(1024, 1024);
    background(255);

    setupCrunchyEffect();

    fill(0);
    interTight = createFont("/Fonts/InterTight-Bold.ttf", 128);

    // textFont(interTight, 300);
    // textSize(300);
    // text("R", width/2 - 90, height/2 + 100);
    
    ellipse(width/2, height/2, width-100, height-100);	
}

void draw() {
    opacityCount++;

    if(opacityCount > 10){
        opacityCount = 0;
        fill(255, 255, 255, 10);
    }

    for(int i = 0; i < blobs.size(); i++){
        blobs.get(i).update();
    }

    for(int i = 0; i < otherBodyParts.size(); i++){
        otherBodyParts.get(i).draw();
    }

    updateCrunchyEffect();
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

void keyPressed() {
    if (key == 'p') {
        scale(2);
        saveFrame("output/####.tiff");
    }
}
