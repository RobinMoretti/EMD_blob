import java.util.HashMap;

ArrayList<BlobObject> blobs = new ArrayList<BlobObject>();
ArrayList<BodyPart> otherBodyParts = new ArrayList<BodyPart>();
HashMap<Integer, ArrayList<BodyPart>> grid = new HashMap<Integer, ArrayList<BodyPart>>();
int cellSize = 100; // Size of each spatial grid cell
int opacityCount = 0;
boolean usePixelEffect = true;

PFont interTight;
float timeToSaveFrameAndStop;
int minTimeToSaveFrameAndStop = 6;
int maxTimeToSaveFrameAndStop = 17;

String letter = "A";
int renderCount = 1;
int saveFrameIntervale = 1 * 1000;

void setup() {
    println("setup !!!!");
    size(1000, 1000);
    background(255);

    setupCrunchyEffect();

    fill(0);
    interTight = createFont("/Fonts/InterTight-Bold.ttf", 128);

    textFont(interTight, 300);
    textSize(380);
    textAlign(CENTER, CENTER);
    text(letter, width/2, height/2);
    
    // ellipse(width/2, height/2, width-100, height-100);	
    
    // add randomly blobs
    int randomBlobCount = (int)random(1, 4);

    for(int i = 0; i < randomBlobCount; i++){
        PVector blobPosition = new PVector();
        boolean isInside = false;
        
        // Keep trying positions until we find one inside the letter
        while (!isInside) {
            // Generate random positions within the bounds of the text
            float angle = random(TWO_PI);
            float distance = random(0, width * 0.3);
            blobPosition.x = width/2 + cos(angle) * distance;
            blobPosition.y = height/2 + sin(angle) * distance;
            
            // Check if the pixel at this position is black (part of the text)
            color pixelColor = get(int(blobPosition.x), int(blobPosition.y));
            if (brightness(pixelColor) < 128) { // If dark enough, it's part of the letter
                isInside = true;
            }
        }

        PVector blobVelocity = PVector.random2D();
        blobVelocity.mult(2);

        blobs.add(new BlobObject(blobPosition, blobVelocity, null));
    }

    // setup radnom time
    timeToSaveFrameAndStop = random(minTimeToSaveFrameAndStop * 1000, maxTimeToSaveFrameAndStop * 1000);
    lastTime = millis();
    lastTimeBis = millis();
}

long lastTime = 0;
long lastTimeBis = 0;
final int FRAME_SKIP = 2; // Only update physics every X frames

void draw() {
    // Only update physics every FRAME_SKIP frames
    if (frameCount % FRAME_SKIP == 0) {
        updateSpatialGrid();
        
        for(int i = 0; i < blobs.size(); i++){
            blobs.get(i).update();
        }
    }
    
    // Always draw
    // for(int i = 0; i < blobs.size(); i++){
    //     blobs.get(i).draw();
    // }

    // for(int i = 0; i < otherBodyParts.size(); i++){
    //     otherBodyParts.get(i).draw();
    // }

    updateCrunchyEffect();

    // save frame every 30 seconds
    if (millis() - lastTimeBis > saveFrameIntervale) {
        saveFrame(getFileName());
        lastTimeBis = millis();
    }

    // check if we need to save frame and stop
    //filter blobs by speed 0
    boolean allStopped = true;

    for (BlobObject blob : blobs) {
        if (blob.velocity.mag() > 0) {
            allStopped = false;
            break;
        }
    }


    if (millis() - lastTime > timeToSaveFrameAndStop || allStopped) {
        saveFrame(getFileName());
        noLoop();
        restart();
    }
}

String getFileName() {
    return "output/" + "render-" + letter + "-" + renderCount + "-" + System.currentTimeMillis() + ".tiff";
}
void restart(){
    renderCount++;
    
    if(renderCount > 5){
        renderCount = 1;
        // get next letter in the alphabet
        letter = Character.toString((char)(letter.charAt(0) + 1));
    }
    background(255);
    blobs.clear();
    otherBodyParts.clear();
    grid.clear();
    setup();
    loop();
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

        blobs.add(new BlobObject(blobPosition, blobVelocity, null));
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

void updateSpatialGrid() {
  grid.clear();
  
  // Add otherBodyParts to grid
  for (BodyPart bp : otherBodyParts) {
    int cellX = floor(bp.position.x / cellSize);
    int cellY = floor(bp.position.y / cellSize);
    int cellKey = cellX * 1000 + cellY; // Simple hash for the cell
    
    if (!grid.containsKey(cellKey)) {
      grid.put(cellKey, new ArrayList<BodyPart>());
    }
    grid.get(cellKey).add(bp);
  }
  
  // Add blob bodyParts to grid
  for (BlobObject blob : blobs) {
    for (BodyPart bp : blob.bodyParts) {
      int cellX = floor(bp.position.x / cellSize);
      int cellY = floor(bp.position.y / cellSize);
      int cellKey = cellX * 1000 + cellY;
      
      if (!grid.containsKey(cellKey)) {
        grid.put(cellKey, new ArrayList<BodyPart>());
      }
      grid.get(cellKey).add(bp);
    }
  }
}
