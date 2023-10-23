import java.util.ArrayList;

int width = 800;
float aspect_ratio = 5.0/8.0;
//float minDist = 0.000012;
boolean isMousePressed = false;
Vec2 mousePos = new Vec2(0, 0);

float k_smooth_radius = 0.06;

float k_stiff = 150.0;
float k_stiffN = 1000.0;
float k_rest_density = 0.2;
float grab_radius = 0.08;
int n = 40;
int r = 15;
float damping = 0.90; 
Vec2 ground = new Vec2();
Vec2 waterbody = new Vec2();

ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<Particle> wb = new ArrayList<Particle>();

void setup() {
  size(800, 500);
  
  waterbody = new Vec2(0, height * 0.8);
  for (int i = 0; i < r; i++) {
    for (int j = 0; j < n; j++) {
      float x = -1 + 2 * j / float(n) + 0.1 * i / float(r);
      float y = (aspect_ratio * (0.5 - 1.5 * i / float(r)))+(-0.625 + 0.25);
      particles.add(new Particle(x, y));
    }
  }
  
  for(int i = 0; i < 80; i++) {
    for(int j = 0; j < 5; j++){
      float x = i*5*2 + 5;
      float y = (500 - j*5*2) + 5;
      
      wb.add(new Particle(x,y));
    }
  }
  
  
}


long lastFrameStart = millis();
void draw() {
  background(10, 20, 25);
  
  float dt = (millis() - lastFrameStart) / 1000.0;  // Calculate the time elapsed since the last frame in seconds
  lastFrameStart = millis();
    
  mousePos.x = mouseX * 1.0 / width * 2 - 1;
  mousePos.y = mouseY * 1.0 / (width * aspect_ratio) * 2 - aspect_ratio;
  
  for (int i = 0; i < 10; i++) {
    float sim_dt = dt / 10.0;
    sim_dt = min(sim_dt, 0.002);
    simulateSPH(particles, k_smooth_radius, k_rest_density, k_stiff, k_stiffN, mousePos, grab_radius, aspect_ratio, sim_dt);
  }

  // Draw particles
  fill(253, 235, 235);
  circle(125, 100, 67);
  
  for (Particle p : particles) {
    float q = p.press / 30.0;
    fill(178.5-q*0.5,204-q*0.5,255-q*0.5);
    circle(map(p.pos.x, -1, 1, 0, width), map(p.pos.y, -aspect_ratio, aspect_ratio, 0, height), 12);
  }
  
  
  for(Particle p : wb)
  {
    fill(255,255,255);
    circle(p.pos.x, p.pos.y, 10);
  }
  //System.out.println(" millis "+ (millis()-lastFrameStart)/1000.0);
}

void mousePressed() {
  isMousePressed = true;
  for (Particle p : particles) {
    float d = dist(mouseX, mouseY, map(p.pos.x, -1, 1, 0, width), map(p.pos.y, -aspect_ratio, aspect_ratio, 0, height));
    p.grabbed = (d < grab_radius * width);
  }
}

void mouseReleased() {
  isMousePressed = false;
  for (Particle p : particles) {
    p.grabbed = false;
  }
}

void simulateSPH(ArrayList<Particle> particles, float k_smooth_radius, float k_rest_density, float k_stiff, float k_stiffN, Vec2 mousePos, float grab_radius, float aspect_ratio, float dt) {
  long st=millis();
  System.out.println("  Start timesph  " + st/1000.0);
  for (Particle p : particles) {
    p.vel = p.pos.minus(p.oldPos).times(1/dt);
    p.vel.add(new Vec2(0.0, 230).times(dt));
    
    if (p.pos.y > aspect_ratio-(0.02083333*5)) {
      p.pos.y = aspect_ratio-(0.02083333*5);
      p.vel.y *= -0.2;  // Bounce with some restitution
    }
    
    if (p.pos.x < -1.0) {
      p.pos.x = -1.0;
      p.vel.x *= -0.2;
    }
    if (p.pos.x > 1.0) {
      p.pos.x = 1.0;
      p.vel.x *= -0.2;
    }
    
    if (p.grabbed) {
      p.vel.add(mousePos.minus(p.pos).times(1/grab_radius).minus(p.vel).times(230).times(dt));
    }
    
    p.oldPos = p.pos;
    p.pos.add(p.vel.times(dt));
    p.dens = 0.0;
    p.densN = 0.0;
  }
  int np = 0;
  ArrayList<Pair> pairs = new ArrayList<Pair>();
  for (int i = 0; i < particles.size(); i++) {
    for (int j = 0; j < particles.size(); j++) {
      if (i < j) {
        Particle particleA = particles.get(i);
        Particle particleB = particles.get(j);
        float dist = particles.get(i).pos.distanceTo(particles.get(j).pos);
        //Vec2 distVec = particleA.pos.minus(particleB.pos);

        if (dist < k_smooth_radius) {
          float q = 1 - (dist / k_smooth_radius);
          pairs.add(new Pair(particles.get(i), particles.get(j), q));
          
          pairs.get(np).p1.dens += (pairs.get(np).q * pairs.get(np).q);
          pairs.get(np).p2.dens += (pairs.get(np).q * pairs.get(np).q);
          pairs.get(np).p1.densN += (pairs.get(np).q * pairs.get(np).q * pairs.get(np).q);
          pairs.get(np).p2.densN += (pairs.get(np).q * pairs.get(np).q * pairs.get(np).q);
          np++;
          //particles.get(i).dens += (p)
          //float pushApart = (k_smooth_radius - dist) / 2.0;
          //Vec2 pushVec = distVec.normalized().times(pushApart);
          //particleA.pos.add(pushVec);
          //particleB.pos.subtract(pushVec);
        }
      }
    }
    particles.get(i).press = k_stiff * (particles.get(i).dens - k_rest_density);
    particles.get(i).pressN = k_stiffN * particles.get(i).densN;
    if (particles.get(i).press > 30) particles.get(i).press = 30;
    if (particles.get(i).pressN > 300) particles.get(i).pressN = 300;
  }
  
  for (Pair pair : pairs) {
    Particle a = pair.p1;
    Particle b = pair.p2;
    float total_pressure = (a.press + b.press) * pair.q + (a.pressN + b.pressN) * pair.q2;
    float displace = total_pressure * sq(dt) + 0.000499;
    a.pos.add((a.pos.minus(b.pos).normalized()).times(displace));
    b.pos.add((b.pos.minus(a.pos).normalized()).times(displace));
  }
  System.out.println("  End timesph  " +  ((millis()-st)/1000.0));
}

public class Vec2 {
  public float x, y;
  
  public Vec2(){
    this.x = 0.0;
    this.y = 0.0;
  }
  
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ "," + y +")";
  }
  
  public float length(){
    return sqrt(x*x+y*y);
  }
  
  public float lengthSqr(){
    return x*x+y*y;
  }
  
  public Vec2 plus(Vec2 rhs){
    return new Vec2(x+rhs.x, y+rhs.y);
  }
  
  public Vec2 rotate(float angle) {
    float newX = x * cos(angle) - y * sin(angle);
    float newY = x * sin(angle) + y * cos(angle);
    return new Vec2(newX, newY);
  }
  
  public void add(Vec2 rhs){
    x += rhs.x;
    y += rhs.y;
  }
  
  public Vec2 minus(Vec2 rhs){
    return new Vec2(x-rhs.x, y-rhs.y);
  }
  
  public void subtract(Vec2 rhs){
    x -= rhs.x;
    y -= rhs.y;
  }
  
  public Vec2 times(float rhs){
    return new Vec2(x*rhs, y*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
  }
  
  public void clampToLength(float maxL){
    float magnitude = sqrt(x*x + y*y);
    if (magnitude > maxL){
      x *= maxL/magnitude;
      y *= maxL/magnitude;
    }
  }
  
  public void setToLength(float newL){
    float magnitude = sqrt(x*x + y*y);
    x *= newL/magnitude;
    y *= newL/magnitude;
  }
  
  public void normalize(){
    float magnitude = sqrt(x*x + y*y);
    x /= magnitude;
    y /= magnitude;
  }
  
  public Vec2 normalized(){
    float magnitude = sqrt(x*x + y*y);
    return new Vec2(x/magnitude, y/magnitude);
  }
  
  public Vec2 perpendicular() {
    return new Vec2(-y, x);
  }

  public Vec2 reflect(Vec2 normal) {
    float dotProduct = 2 * dot(this, normal);
    return new Vec2(x - dotProduct * normal.x, y - dotProduct * normal.y);
  }
  
  public float distanceTo(Vec2 rhs){
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    return sqrt(dx*dx + dy*dy);
  }
}

Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

float cross(Vec2 a, Vec2 b) {
  return a.x * b.y - a.y * b.x;
}

Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}

class Particle {
  Vec2 pos, oldPos, vel;
  float press, dens, pressN, densN;
  boolean grabbed;

  Particle(float x, float y) {
    this.pos = new Vec2(x, y);
    this.oldPos = new Vec2(x, y);
    //this.vel = new Vec2(0, 10);
    this.vel = new Vec2(0, 75);
    this.press = 0.0;
    this.dens = 0.0;
    this.pressN = 0.0;
    this.densN = 0.0;
    this.grabbed = false;
  }
}

class Pair {
  Particle p1, p2;
  float q, q2, q3;

  Pair(Particle p1, Particle p2, float q) {
    this.p1 = p1;
    this.p2 = p2;
    this.q = q;
    this.q2 = q * q;
    this.q3 = q * q * q;
  }
}
