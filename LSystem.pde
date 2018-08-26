class LSystem {
    
    private String axiom;
    private int n;
    private String pattern;

    ArrayList<LSystemRule> rules;
    
    public LSystem(String axiom, int n) {
        this.axiom = axiom;
        this.n = n;
        rules = new ArrayList<LSystemRule>();
    }

    public void addRule(LSystemRule rule) {
        rules.add(rule);
    }

    public void generate() {
        pattern = generateHelper(axiom, n);
    }

    private String generateHelper(String gen, int n) {
        assert(gen != "" && gen != null);
        assert(n >= 0);
        if (n == 0) return gen;
        StringBuilder next_gen = new StringBuilder();
        for (char g : gen.toCharArray()) {
            for (LSystemRule lsr : rules) {
                if (String.valueOf(g).equals(lsr.pre)) {
                    //println("appending: '" + next_gen + "' to: '" + lsr.post + "'");
                    next_gen.append(lsr.post);
                    break;
                }
            }
            next_gen.append(g);
        }
        return generateHelper(next_gen.toString(), n-1);
    }

    public String show() {
        return pattern;
    }

    public class LSystemRule {
    
        public String pre;
        public String post;
        
        public LSystemRule(String pre, String post) {
             this.pre = pre;
             this.post = post;
        }
    
    }

}

