class LSystem {
    
    private String axiom;
    private int n;
    private String pattern;

    ArrayList<LSystemRule> rules;
    
    public LSystem(String axiom, int n) {
        this.axiom = axiom;
        this.n = n;
        pattern = generate(axiom, n);
    }

    private String generate(String gen, int n) {
        assert(gen != "" && gen != null);
        assert(n > 0);
        if (n == 0) return gen;
        String next_gen = new String("");
        for (char g : gen.toCharArray()) {
            for (LSystemRule lsr : rules) {
                if (String.valueOf(g).equals(lsr.pre)) {
                    next_gen = next_gen.concat(lsr.post);
                    break;
                }
            }
            next_gen = next_gen.concat(String.valueOf(g));
        }
        return generate(next_gen, n-1);
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

