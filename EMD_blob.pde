import java.util.HashMap;

ArrayList<BlobObject> blobs = new ArrayList<BlobObject>();
ArrayList<BodyPart> otherBodyParts = new ArrayList<BodyPart>();
HashMap<Integer, ArrayList<BodyPart>> grid = new HashMap<Integer, ArrayList<BodyPart>>();
int cellSize = 100; // Size of each spatial grid cell
int opacityCount = 0;
boolean usePixelEffect = true;

PFont interTight;
float timeToSaveFrameAndStop;

int renderCount = 15;

void setup() {
    size(2000, 2000);
    background(255);

    setupCrunchyEffect();

    fill(0);
    interTight = createFont("/Fonts/InterTight-Bold.ttf", 128);

    textFont(interTight, 300);
    textSize(250);
    //text("Un titre incroyable", width/2 - 300, height/2 + 100);
    
    // ellipse(width/2, height/2, width-100, height-100);	
    
    // add randomly blobs
    int randomBlobCount = (int)random(1, 3);

    for(int i = 0; i < randomBlobCount; i++){
        PVector blobPosition = new PVector();
        // Generate random positions closer to the center
        float angle = random(TWO_PI);
        float distance = random(0, width * 0.3); // Limit distance from center
        blobPosition.x = width/2 + cos(angle) * distance;
        blobPosition.y = height/2 + sin(angle) * distance;

        PVector blobVelocity = PVector.random2D();
        blobVelocity.mult(2);

        blobs.add(new BlobObject(blobPosition, blobVelocity, null));
    }

    // setup radnom time
    timeToSaveFrameAndStop = random(100 * 1000, 500 * 1000);
    lastTime = millis();
}

long lastTime = 0;
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
    if (millis() - lastTime > 30 * 1000) {
        saveFrame(getFileName());
        lastTime = millis();
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


	//saveFrame("output/####.png");
}

String getFileName() {
    return "output/" + "render-" + renderCount + "-" + System.currentTimeMillis() + ".tiff";
}
void restart(){
    renderCount++;
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
