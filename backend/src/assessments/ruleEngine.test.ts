import { evaluateRules } from './ruleEngine';
import { RuleEngineInput, RuleDoc, AssessmentDoc } from '../shared/types';

// Helper to create minimal rule configs
function createDefaultRules(): RuleDoc[] {
  return [
    {
      id: 'R-001',
      type: 'Escalation',
      title: 'Crisis Alert',
      description: 'Extremely severe depression or anxiety',
      formula: 'dep=ES OR anx=ES',
      actions: [],
      isActive: true,
      parameters: [],
    },
    {
      id: 'R-C01',
      type: 'Contextual',
      title: 'Triple Moderate Escalation',
      description: 'All three subscales moderate',
      formula: 'dep=M AND anx=M AND str=M',
      actions: [],
      isActive: true,
      parameters: [],
    },
    {
      id: 'R-C02',
      type: 'Contextual',
      title: 'Exam Period',
      description: 'High stress during exams',
      formula: 'in_exam_period AND str>=M',
      actions: [],
      isActive: true,
      parameters: [],
    },
    {
      id: 'R-C03',
      type: 'Contextual',
      title: 'Repeat High-Risk',
      description: 'Previous HIGH/CRITICAL + current Mild',
      formula: 'prev_high_critical AND any>=M',
      actions: [],
      isActive: true,
      parameters: [],
    },
  ];
}

describe('Rule Engine', () => {
  describe('Explicit rule evaluation', () => {
    it('should fire R-001 (CRITICAL) when depression is Extremely Severe', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Extremely Severe', anx: 'Normal', str: 'Normal' },
        normalisedScores: { dep: 42, anx: 0, str: 0 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-001');
      expect(result.riskLevel).toBe('CRITICAL');
    });

    it('should fire R-001 (CRITICAL) when anxiety is Extremely Severe', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Extremely Severe', str: 'Normal' },
        normalisedScores: { dep: 0, anx: 42, str: 0 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-001');
      expect(result.riskLevel).toBe('CRITICAL');
    });

    it('should fire R-002 (HIGH) when depression Severe AND anxiety Moderate', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Severe', anx: 'Moderate', str: 'Normal' },
        normalisedScores: { dep: 21, anx: 10, str: 0 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-002');
      expect(result.riskLevel).toBe('HIGH');
    });

    it('should fire R-003 (HIGH) when stress is Severe', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Normal', str: 'Severe' },
        normalisedScores: { dep: 0, anx: 0, str: 26 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-003');
      expect(result.riskLevel).toBe('HIGH');
    });

    it('should fire R-003 (HIGH) when stress is Extremely Severe', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Normal', str: 'Extremely Severe' },
        normalisedScores: { dep: 0, anx: 0, str: 34 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-003');
      expect(result.riskLevel).toBe('HIGH');
    });

    it('should fire R-004 (MODERATE) when depression is Moderate', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Moderate', anx: 'Normal', str: 'Normal' },
        normalisedScores: { dep: 14, anx: 0, str: 0 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-004');
      expect(result.riskLevel).toBe('MODERATE');
    });

    it('should fire R-004 (MODERATE) when anxiety is Moderate', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Moderate', str: 'Normal' },
        normalisedScores: { dep: 0, anx: 10, str: 0 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-004');
      expect(result.riskLevel).toBe('MODERATE');
    });

    it('should fire R-005 when stress Moderate AND depression Mild', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Mild', anx: 'Normal', str: 'Moderate' },
        normalisedScores: { dep: 10, anx: 0, str: 19 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-005');
      expect(result.riskLevel).toBe('MODERATE');
    });

    it('should fire R-005 when stress Moderate AND anxiety Mild', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Mild', str: 'Moderate' },
        normalisedScores: { dep: 0, anx: 8, str: 19 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-005');
      expect(result.riskLevel).toBe('MODERATE');
    });

    it('should fire R-006 when dep Mild AND anx Normal AND str Normal', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Mild', anx: 'Normal', str: 'Normal' },
        normalisedScores: { dep: 10, anx: 0, str: 0 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-006');
      expect(result.riskLevel).toBe('LOW');
    });

    it('should fire R-007 when all Normal/Mild', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Normal', str: 'Mild' },
        normalisedScores: { dep: 0, anx: 0, str: 15 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-007');
      expect(result.riskLevel).toBe('NORMAL');
    });

    it('should fire R-000 fallback for unusual combinations', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Mild', anx: 'Mild', str: 'Mild' },
        normalisedScores: { dep: 10, anx: 8, str: 15 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.firedRuleId).toBe('R-000');
      expect(result.riskLevel).toBe('LOW');
    });

    it('should respect isActive flag on rules', async () => {
      const rules = createDefaultRules();
      // Disable R-001
      rules[0].isActive = false;

      const input: RuleEngineInput = {
        severities: { dep: 'Extremely Severe', anx: 'Normal', str: 'Normal' },
        normalisedScores: { dep: 42, anx: 0, str: 0 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: rules,
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      // Should not fire R-001, should continue to next rules
      // dep=ES but no rule fires, so should hit fallback
      expect(result.firedRuleId).not.toBe('R-001');
    });
  });

  describe('Tacit rule evaluation (R-C01)', () => {
    it('should apply R-C01 escalation: all Moderate → HIGH', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Moderate', anx: 'Moderate', str: 'Moderate' },
        normalisedScores: { dep: 14, anx: 10, str: 19 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      // R-004 fires first (dep or anx is Moderate) → MODERATE
      // But R-C01 should escalate to HIGH
      expect(result.firedRuleId).toBe('R-004');
      expect(result.riskLevel).toBe('HIGH');
      expect(result.appliedTacitRules).toContain('R-C01');
    });

    it('should not apply R-C01 if not all three are Moderate', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Moderate', anx: 'Moderate', str: 'Mild' },
        normalisedScores: { dep: 14, anx: 10, str: 15 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.appliedTacitRules).not.toContain('R-C01');
    });
  });

  describe('Tacit rule evaluation (R-C02)', () => {
    it('should apply R-C02 during exam period with Moderate+ stress', async () => {
      const examDate = new Date('2026-06-20');

      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Normal', str: 'Moderate' },
        normalisedScores: { dep: 0, anx: 0, str: 19 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: examDate,
      };

      const result = await evaluateRules(input);
      expect(result.appliedTacitRules).toContain('R-C02');
    });

    it('should not apply R-C02 outside exam period', async () => {
      const offDate = new Date('2026-05-15');

      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Normal', str: 'Moderate' },
        normalisedScores: { dep: 0, anx: 0, str: 19 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: offDate,
      };

      const result = await evaluateRules(input);
      expect(result.appliedTacitRules).not.toContain('R-C02');
    });
  });

  describe('Tacit rule evaluation (R-C03)', () => {
    it('should escalate to HIGH when previous HIGH + current Mild', async () => {
      const previousAssessment: Partial<AssessmentDoc> = {
        riskLevel: 'HIGH',
      };

      const input: RuleEngineInput = {
        severities: { dep: 'Mild', anx: 'Normal', str: 'Normal' },
        normalisedScores: { dep: 10, anx: 0, str: 0 },
        userId: 'student1',
        previousAssessments: [previousAssessment as AssessmentDoc],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      // R-006 should fire first (dep Mild, anx Normal, str Normal) → LOW
      // But R-C03 should escalate to HIGH
      expect(result.firedRuleId).toBe('R-006');
      expect(result.riskLevel).toBe('HIGH');
      expect(result.appliedTacitRules).toContain('R-C03');
    });

    it('should escalate to HIGH when previous CRITICAL + current Mild', async () => {
      const previousAssessment: Partial<AssessmentDoc> = {
        riskLevel: 'CRITICAL',
      };

      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Mild', str: 'Normal' },
        normalisedScores: { dep: 0, anx: 8, str: 0 },
        userId: 'student1',
        previousAssessments: [previousAssessment as AssessmentDoc],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.riskLevel).toBe('HIGH');
      expect(result.appliedTacitRules).toContain('R-C03');
    });

    it('should not apply R-C03 if previous was LOW', async () => {
      const previousAssessment: Partial<AssessmentDoc> = {
        riskLevel: 'LOW',
      };

      const input: RuleEngineInput = {
        severities: { dep: 'Mild', anx: 'Normal', str: 'Normal' },
        normalisedScores: { dep: 10, anx: 0, str: 0 },
        userId: 'student1',
        previousAssessments: [previousAssessment as AssessmentDoc],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.appliedTacitRules).not.toContain('R-C03');
    });

    it('should not apply R-C03 if no previous assessments', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Mild', anx: 'Normal', str: 'Normal' },
        normalisedScores: { dep: 10, anx: 0, str: 0 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.appliedTacitRules).not.toContain('R-C03');
    });
  });

  describe('Recommendation generation', () => {
    it('should build meaningful recommendation for CRITICAL', async () => {
      const input: RuleEngineInput = {
        severities: { dep: 'Extremely Severe', anx: 'Normal', str: 'Normal' },
        normalisedScores: { dep: 42, anx: 0, str: 0 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: new Date(),
      };

      const result = await evaluateRules(input);
      expect(result.recommendation.title).toContain('Crisis');
      expect(result.recommendation.body).toContain('immediate');
      expect(result.recommendation.actions.length).toBeGreaterThan(0);
    });

    it('should include exam resources in recommendation when R-C02 applies', async () => {
      const examDate = new Date('2026-06-20');

      const input: RuleEngineInput = {
        severities: { dep: 'Normal', anx: 'Normal', str: 'Moderate' },
        normalisedScores: { dep: 0, anx: 0, str: 19 },
        userId: 'student1',
        previousAssessments: [],
        ruleConfigs: createDefaultRules(),
        currentDate: examDate,
      };

      const result = await evaluateRules(input);
      if (result.appliedTacitRules.includes('R-C02')) {
        expect(result.recommendation.body).toContain('exam');
      }
    });
  });
});
