
ArrayList<Blob> blobs = new ArrayList<Blob>();

void setup() {
    size(512, 512);
    
    blobs.add(new Blob());
}

void draw() {
    background(255);
    
    for(int i = 0; i < blobs.size(); i++){
        blobs.get(i).update();
    }
}

void mousePressed() {
}
