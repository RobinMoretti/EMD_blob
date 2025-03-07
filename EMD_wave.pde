Blob[] blobs = new Blob[1];

void setup() {
    size(512, 512);
    
    blobs[0] = new Blob();
}

void draw() {
    background(255);
    
    for(int i = 0; i < blobs.length; i++){
        blobs[i].update();
    }
}

void mousePressed() {
}
