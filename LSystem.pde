class LSystem {

    private String axiom;
    private String pattern;
    private int n;
    private float mod_ang;

    ArrayList<LSystemRule> rules;

    public LSystem(String axiom, int n, float mod_ang) {
        this.axiom = axiom;
        rules = new ArrayList<LSystemRule>();
        this.n = n;
        this.mod_ang = mod_ang;
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
        gen : for (char g : gen.toCharArray()) {
            for (LSystemRule lsr : rules) {
                if (String.valueOf(g).equals(lsr.pre)) {
                    next_gen.append(lsr.post);
                    continue gen;
                }
            }
            next_gen.append(g);
        }
        return generateHelper(next_gen.toString(), n-1);
    }

    public String show() {
        return pattern;
    }

    public float mod_ang() {
        return mod_ang;
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

