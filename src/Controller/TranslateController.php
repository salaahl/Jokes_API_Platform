<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;

class TranslateController extends AbstractController
{
    private HttpClientInterface $httpClient;

    public function __construct(HttpClientInterface $httpClient)
    {
        $this->httpClient = $httpClient;
    }

    #[Route('/translate', name: 'translate')]
    public function translate(Request $request): JsonResponse
    {
        $data = [
            'text' => 'Hello, how are you ?',
            'target_lang' => 'FR',
        ];
        if (!isset($data['text'], $data['target_lang'])) {
            return $this->json(
                ['error' => 'Paramètres invalides, "text" et "target_lang" requis.'],
                Response::HTTP_BAD_REQUEST
            );
        }

        $response = $this->httpClient->request('POST', 'https://api-free.deepl.com/v2/translate', [
            'headers' => [
                'Content-Type' => 'application/x-www-form-urlencoded',
                'Authorization' => 'DeepL-Auth-Key ' . getenv('DEEPL_AUTH_KEY'),
            ],
            'body' => http_build_query([
                'text' => $data['text'],
                'target_lang' => $data['target_lang'],
            ]),
        ]);

        if (200 !== $response->getStatusCode()) {
            return $this->json(
                ['error' => 'Erreur lors de l’appel à DeepL.'],
                Response::HTTP_BAD_GATEWAY
            );
        }

        return $this->json($response->toArray());
    }

    #[Route('/test-route', name: 'test_route', methods: ['GET'])]
    public function testRoute(): JsonResponse
    {
        return $this->json(['status' => 'Route fonctionne !']);
    }
}
