class BodyPart{
	PVector position;
	float size;

	BodyPart(PVector _position, float _size){
		position = _position.copy();
		size = _size;
	} 

	void draw(){
		fill(0, 100);
		noStroke();
		ellipse(position.x, position.y, size, size);
	}
}