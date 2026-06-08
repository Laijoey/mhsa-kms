import {
  computeScores,
  getDepressionSeverity,
  getAnxietySeverity,
  getStressSeverity,
  getSeverityRank,
} from './scoring';

describe('DASS-21 Scoring Module', () => {
  describe('computeScores', () => {
    it('should validate input array length', () => {
      const shortArray = new Array(20).fill(0);
      expect(() => computeScores(shortArray)).toThrow('Expected 21 answers');

      const longArray = new Array(22).fill(0);
      expect(() => computeScores(longArray)).toThrow('Expected 21 answers');
    });

    it('should validate answer values are 0-3', () => {
      const invalidLow = new Array(21).fill(0);
      invalidLow[0] = -1;
      expect(() => computeScores(invalidLow)).toThrow('must be 0-3');

      const invalidHigh = new Array(21).fill(0);
      invalidHigh[0] = 4;
      expect(() => computeScores(invalidHigh)).toThrow('must be 0-3');
    });

    it('should return all Normal for all-zero answers', () => {
      const zeroAnswers = new Array(21).fill(0);
      const result = computeScores(zeroAnswers);

      expect(result.rawScores).toEqual({ dep: 0, anx: 0, str: 0 });
      expect(result.normalisedScores).toEqual({ dep: 0, anx: 0, str: 0 });
      expect(result.severities).toEqual({
        dep: 'Normal',
        anx: 'Normal',
        str: 'Normal',
      });
    });

    it('should return Extremely Severe for all-3 answers', () => {
      const maxAnswers = new Array(21).fill(3);
      const result = computeScores(maxAnswers);

      // Depression: 7 items × 3 = 21 raw, × 2 = 42 normalised
      // Anxiety: 7 items × 3 = 21 raw, × 2 = 42 normalised
      // Stress: 7 items × 3 = 21 raw, × 2 = 42 normalised
      expect(result.rawScores).toEqual({ dep: 21, anx: 21, str: 21 });
      expect(result.normalisedScores).toEqual({ dep: 42, anx: 42, str: 42 });
      expect(result.severities).toEqual({
        dep: 'Extremely Severe',
        anx: 'Extremely Severe',
        str: 'Extremely Severe',
      });
    });

    it('should map items correctly: depression subscale', () => {
      // Depression items: 3, 5, 10, 13, 16, 17, 21 (1-indexed)
      // Set only these to 2, others to 0
      const answers = new Array(21).fill(0);
      answers[2] = 2;  // item 3
      answers[4] = 2;  // item 5
      answers[9] = 2;  // item 10
      answers[12] = 2; // item 13
      answers[15] = 2; // item 16
      answers[16] = 2; // item 17
      answers[20] = 2; // item 21

      const result = computeScores(answers);
      expect(result.rawScores.dep).toBe(14); // 7 items × 2
      expect(result.normalisedScores.dep).toBe(28); // 14 × 2
      expect(result.severities.dep).toBe('Extremely Severe'); // ≥ 28
      expect(result.severities.anx).toBe('Normal'); // 0
      expect(result.severities.str).toBe('Normal'); // 0
    });

    it('should map items correctly: anxiety subscale', () => {
      // Anxiety items: 2, 4, 7, 9, 15, 19, 20 (1-indexed)
      const answers = new Array(21).fill(0);
      answers[1] = 2;  // item 2
      answers[3] = 2;  // item 4
      answers[6] = 2;  // item 7
      answers[8] = 2;  // item 9
      answers[14] = 2; // item 15
      answers[18] = 2; // item 19
      answers[19] = 2; // item 20

      const result = computeScores(answers);
      expect(result.rawScores.anx).toBe(14);
      expect(result.normalisedScores.anx).toBe(28);
      expect(result.severities.anx).toBe('Extremely Severe');
      expect(result.severities.dep).toBe('Normal');
      expect(result.severities.str).toBe('Normal');
    });

    it('should map items correctly: stress subscale', () => {
      // Stress items: 1, 6, 8, 11, 12, 14, 18 (1-indexed)
      const answers = new Array(21).fill(0);
      answers[0] = 2;  // item 1
      answers[5] = 2;  // item 6
      answers[7] = 2;  // item 8
      answers[10] = 2; // item 11
      answers[11] = 2; // item 12
      answers[13] = 2; // item 14
      answers[17] = 2; // item 18

      const result = computeScores(answers);
      expect(result.rawScores.str).toBe(14);
      expect(result.normalisedScores.str).toBe(28);
      expect(result.severities.str).toBe('Severe'); // stress 28 = Severe (≤33)
      expect(result.severities.dep).toBe('Normal');
      expect(result.severities.anx).toBe('Normal');
    });

    it('should handle mixed severity levels', () => {
      // Create an answer pattern:
      // Depression items (1-indexed): 3, 5, 10, 13, 16, 17, 21 (0-indexed: 2, 4, 9, 12, 15, 16, 20)
      // Anxiety items (1-indexed): 2, 4, 7, 9, 15, 19, 20 (0-indexed: 1, 3, 6, 8, 14, 18, 19)
      // Stress items (1-indexed): 1, 6, 8, 11, 12, 14, 18 (0-indexed: 0, 5, 7, 10, 11, 13, 17)
      // Depression: all 1s (7 × 1 = 7 raw, 14 norm) → Moderate (14-20)
      // Anxiety: all 2s (7 × 2 = 14 raw, 28 norm) → Severe (15-19 for anx means 7×2=14, but let's use 3 per item = 21×2=42 for Severe)
      // Stress: all 0s (0 raw, 0 norm) → Normal

      const answers = new Array(21).fill(0);
      // Depression: 6 items with 1 → raw 6, norm 12 → Mild
      [2, 4, 9, 12, 15, 16].forEach((idx) => (answers[idx] = 1));
      // Anxiety: all 7 items with 2 → raw 14, norm 28... but that's > 19, so Extremely Severe
      // Change to: 6 anxiety items with 2 → raw 12, norm 24 → still Extremely Severe (≥20)
      // Actually let's use: 5 anxiety items with 2 → raw 10, norm 20 → exactly Extremely Severe boundary
      [1, 3, 6, 8, 14].forEach((idx) => (answers[idx] = 2)); // 5 items → norm 20 → Extremely Severe
      // Stress: all 0 (default)

      const result = computeScores(answers);
      expect(result.normalisedScores.dep).toBe(12);
      expect(result.severities.dep).toBe('Mild');
      expect(result.normalisedScores.anx).toBe(20);
      expect(result.severities.anx).toBe('Extremely Severe');
      expect(result.normalisedScores.str).toBe(0);
      expect(result.severities.str).toBe('Normal');
    });

    it('should apply ×2 normalisation correctly', () => {
      const answers = new Array(21).fill(1);
      const result = computeScores(answers);

      // Each subscale gets 7 items × 1 = 7 raw
      // Normalised = 7 × 2 = 14
      expect(result.normalisedScores.dep).toBe(14);
      expect(result.normalisedScores.anx).toBe(14);
      expect(result.normalisedScores.str).toBe(14);
    });
  });

  describe('Severity classification (Depression)', () => {
    it('should classify depression Normal (≤9)', () => {
      expect(getDepressionSeverity(0)).toBe('Normal');
      expect(getDepressionSeverity(5)).toBe('Normal');
      expect(getDepressionSeverity(9)).toBe('Normal');
    });

    it('should classify depression Mild (10-13)', () => {
      expect(getDepressionSeverity(10)).toBe('Mild');
      expect(getDepressionSeverity(11)).toBe('Mild');
      expect(getDepressionSeverity(13)).toBe('Mild');
    });

    it('should classify depression Moderate (14-20)', () => {
      expect(getDepressionSeverity(14)).toBe('Moderate');
      expect(getDepressionSeverity(17)).toBe('Moderate');
      expect(getDepressionSeverity(20)).toBe('Moderate');
    });

    it('should classify depression Severe (21-27)', () => {
      expect(getDepressionSeverity(21)).toBe('Severe');
      expect(getDepressionSeverity(24)).toBe('Severe');
      expect(getDepressionSeverity(27)).toBe('Severe');
    });

    it('should classify depression Extremely Severe (≥28)', () => {
      expect(getDepressionSeverity(28)).toBe('Extremely Severe');
      expect(getDepressionSeverity(42)).toBe('Extremely Severe');
    });
  });

  describe('Severity classification (Anxiety)', () => {
    it('should classify anxiety Normal (≤7)', () => {
      expect(getAnxietySeverity(0)).toBe('Normal');
      expect(getAnxietySeverity(7)).toBe('Normal');
    });

    it('should classify anxiety Mild (8-9)', () => {
      expect(getAnxietySeverity(8)).toBe('Mild');
      expect(getAnxietySeverity(9)).toBe('Mild');
    });

    it('should classify anxiety Moderate (10-14)', () => {
      expect(getAnxietySeverity(10)).toBe('Moderate');
      expect(getAnxietySeverity(12)).toBe('Moderate');
      expect(getAnxietySeverity(14)).toBe('Moderate');
    });

    it('should classify anxiety Severe (15-19)', () => {
      expect(getAnxietySeverity(15)).toBe('Severe');
      expect(getAnxietySeverity(17)).toBe('Severe');
      expect(getAnxietySeverity(19)).toBe('Severe');
    });

    it('should classify anxiety Extremely Severe (≥20)', () => {
      expect(getAnxietySeverity(20)).toBe('Extremely Severe');
      expect(getAnxietySeverity(42)).toBe('Extremely Severe');
    });
  });

  describe('Severity classification (Stress)', () => {
    it('should classify stress Normal (≤14)', () => {
      expect(getStressSeverity(0)).toBe('Normal');
      expect(getStressSeverity(14)).toBe('Normal');
    });

    it('should classify stress Mild (15-18)', () => {
      expect(getStressSeverity(15)).toBe('Mild');
      expect(getStressSeverity(16)).toBe('Mild');
      expect(getStressSeverity(18)).toBe('Mild');
    });

    it('should classify stress Moderate (19-25)', () => {
      expect(getStressSeverity(19)).toBe('Moderate');
      expect(getStressSeverity(22)).toBe('Moderate');
      expect(getStressSeverity(25)).toBe('Moderate');
    });

    it('should classify stress Severe (26-33)', () => {
      expect(getStressSeverity(26)).toBe('Severe');
      expect(getStressSeverity(30)).toBe('Severe');
      expect(getStressSeverity(33)).toBe('Severe');
    });

    it('should classify stress Extremely Severe (≥34)', () => {
      expect(getStressSeverity(34)).toBe('Extremely Severe');
      expect(getStressSeverity(42)).toBe('Extremely Severe');
    });
  });

  describe('getSeverityRank', () => {
    it('should return correct ordinal ranks', () => {
      expect(getSeverityRank('Normal')).toBe(0);
      expect(getSeverityRank('Mild')).toBe(1);
      expect(getSeverityRank('Moderate')).toBe(2);
      expect(getSeverityRank('Severe')).toBe(3);
      expect(getSeverityRank('Extremely Severe')).toBe(4);
    });
  });
});
