class Blob{
	PVector position, velocity, acceleration;
	ArrayList<BodyPart> bodyParts = new ArrayList<BodyPart>();

	float maxSpeed = 1;
	float maxForce = 0.1;
	float minDistance = 25;
	float perceptionRadius = 100;

	Blob(){
		position = new PVector();
		velocity = new PVector();
		acceleration = new PVector();

		position.x = width/2;
		position.y = height/2;
		
		// go in a random direction
		velocity.x = random(-1, 1);
		velocity.y = random(-1, 1);

		// add many body part randomly 
		for (int i = 0; i < 100; i++) {
			PVector position = new PVector(random(width), random(height));
			bodyParts.add(new BodyPart(position, random(5, 20)));
		}
		
	} 

	void update(){
    	PVector repulsion = new PVector(0, 0);
    
		for (BodyPart bodyPart : bodyParts) {
			float distance = PVector.dist(position, bodyPart.position);

			if (distance < 50) { // Seuil pour considération de répulsion
				PVector diff = PVector.sub(position, bodyPart.position);
				diff.normalize();
				diff.div(distance);  // Diminue l'effet avec la distance
				repulsion.add(diff);
			}
		}

		// Applique la force de répulsion à la vitesse
		repulsion.limit(maxSpeed);      // Limiter la force pour une stability
		velocity.add(repulsion);
		velocity.limit(maxSpeed);       // Limiter la vitesse pour garder le contrôle

		// Met à jour la position
		position.add(velocity);

		draw();

		// draw all body parts
		for (BodyPart bodyPart : bodyParts) {
			bodyPart.draw();
		}
	}

	void draw(){
		fill(0, 100);
		ellipse(position.x, position.y, 10, 10);

		// draw the perception radius
		noFill();
		stroke(0, 100);
		ellipse(position.x, position.y, perceptionRadius, perceptionRadius);
	}

}