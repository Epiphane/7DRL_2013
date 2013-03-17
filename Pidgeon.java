import java.lang.Math;

public class Pidgeon {
	public static String[] vowels = new String[] {"a","e","i","o","u"};
	public static String[] loneConsonants = new String[] {"d","j","m","n","qu","t"};
	public static String[] doubleLetters = new String[] {"mm","nn","tt","ll","dd","ff","kk","ss"};
	public static String[] followerConsonants = new String[] {"h","l","r"};
	public static String[] leaderConsonants = new String[] {"b","c","f","g","k","p","s"};
	
	private String name;
	
	public Pidgeon() {
		name = "";
		while(name.length() < Math.random() * 16) {
			switch((int) (Math.random() * 4)) {
			case 0:
				name += randomLetter(loneConsonants);
				name += randomLetter(vowels);
				break;
			case 1:
				if(name.length() > 1)
					name += randomLetter(doubleLetters);
				name += randomLetter(vowels);
				break;
			case 2:
				name += randomLetter(leaderConsonants);
				name += randomLetter(vowels);
				break;
			case 3:
				name += randomLetter(leaderConsonants);
				name += randomLetter(followerConsonants);
			case 4:
				name += randomLetter(vowels);
				break;
			}
		}
	}
	
	public String talk() {
		return "Hi! I'm "+name;
	}

	public void greet() {
		System.out.println("Welcome! I'm "+name+", a Pidgeon living here.");
		System.out.println("It might look like it, but I am not a Pigeon.");
		System.out.println("I am a Pidgeon...they are very different things.");
		System.out.println("If you want to learn more about what youre doing here, go check out the town hall");

	}
	
	public static String randomLetter(String[] letters) {
		int length = letters.length;
		
		return letters[(int) (Math.random()*length)];
	}
}
